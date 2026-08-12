#!/usr/bin/env bash
set -euo pipefail

echo "== Installing DuckDB CLI =="
curl -fsSL https://install.duckdb.org | sh
export PATH="$HOME/.duckdb/cli/latest:$PATH"
echo 'export PATH="$HOME/.duckdb/cli/latest:$PATH"' >> "$HOME/.bashrc"

echo "== Installing Claude Code =="
npm install -g @anthropic-ai/claude-code

echo "== Installing Codex CLI =="
export CODEX_NON_INTERACTIVE=1
curl -fsSL https://chatgpt.com/codex/install.sh | sh
echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
export PATH="$HOME/.local/bin:$PATH"

echo "== Verifying workshop data =="
if [ ! -f "data/workshop.duckdb" ]; then
  echo "ERROR: data/workshop.duckdb is missing. Check Git LFS pulled correctly (git lfs pull)."
  exit 1
fi

ROW_COUNT=$("$HOME/.duckdb/cli/latest/duckdb" data/workshop.duckdb -csv -noheader -c "SELECT count(*) FROM transactions;")
echo "Smoke test: transactions table has ${ROW_COUNT} rows."

if [ "$ROW_COUNT" -lt 1 ]; then
  echo "ERROR: transactions table is empty — data did not load correctly."
  exit 1
fi

echo "== Setup complete =="
