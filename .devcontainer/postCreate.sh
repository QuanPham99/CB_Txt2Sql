#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

echo "== Wiring up git credentials for LFS =="
# Codespaces injects GITHUB_TOKEN into every container for the repo's own
# remote. Git doesn't use it automatically, so point the credential helper
# at it — this is what lets `git lfs pull` run non-interactively below.
if [ -n "${GITHUB_TOKEN:-}" ]; then
  git config --global credential."https://github.com".helper \
    '!f() { echo username=x-access-token; echo "password=$GITHUB_TOKEN"; }; f'
fi

echo "== Ensuring git-lfs is installed =="
if ! command -v git-lfs >/dev/null 2>&1; then
  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update -qq && sudo apt-get install -y -qq git-lfs
  elif command -v apk >/dev/null 2>&1; then
    sudo apk add --no-cache git-lfs
  else
    echo "ERROR: no known package manager (apt-get/apk) to install git-lfs." >&2
    exit 1
  fi
fi
git lfs install --local

echo "== Pulling LFS data (data/workshop.duckdb) =="
git lfs pull

if head -c 20 data/workshop.duckdb 2>/dev/null | grep -q "git-lfs"; then
  echo "ERROR: data/workshop.duckdb is still an LFS pointer, not the real file." >&2
  echo "        Run 'git lfs pull' manually once you have GitHub credentials." >&2
  exit 1
fi

echo "== Installing DuckDB =="
IS_MUSL=false
if [ -f /etc/os-release ] && grep -qi "alpine" /etc/os-release; then
  IS_MUSL=true
fi

if [ "$IS_MUSL" = false ]; then
  # Standard glibc host (the devcontainer's declared Ubuntu base) — the
  # official installer works fine here.
  curl -fsSL https://install.duckdb.org | sh
  export PATH="$HOME/.duckdb/cli/latest:$PATH"
  echo 'export PATH="$HOME/.duckdb/cli/latest:$PATH"' >> "$HOME/.bashrc"
else
  # musl (Alpine) host — the glibc-linked CLI binary won't run even under
  # gcompat (it's missing symbols like __res_init at runtime). Use the
  # `duckdb` Python package instead, which ships musllinux wheels, behind a
  # thin CLI-compatible shim so SKILL.md's documented commands still work.
  command -v pip3 >/dev/null 2>&1 || sudo apk add --no-cache py3-pip
  python3 -m pip install --break-system-packages --only-binary=:all: --quiet duckdb
  mkdir -p "$HOME/.local/bin"
  cp "$REPO_ROOT/.devcontainer/duckdb_shim.py" "$HOME/.local/bin/duckdb"
  chmod +x "$HOME/.local/bin/duckdb"
  export PATH="$HOME/.local/bin:$PATH"
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
fi

echo "== Installing Claude Code =="
npm install -g @anthropic-ai/claude-code

echo "== Installing Codex CLI =="
export CODEX_NON_INTERACTIVE=1
curl -fsSL https://chatgpt.com/codex/install.sh | sh
echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
export PATH="$HOME/.local/bin:$PATH"

echo "== Verifying workshop data =="
ROW_COUNT=$(duckdb data/workshop.duckdb -csv -noheader -c "SELECT count(*) FROM transactions;")
echo "Smoke test: transactions table has ${ROW_COUNT} rows."

if [ "$ROW_COUNT" -lt 1 ]; then
  echo "ERROR: transactions table is empty — data did not load correctly." >&2
  exit 1
fi

echo "== Setup complete =="
