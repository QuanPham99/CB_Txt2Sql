#!/usr/bin/env bash
# One-command local setup for the Text-to-SQL Skills Workshop.
# Run this from anywhere after cloning the repo:
#
#   ./setup.sh
#
# It installs the DuckDB CLI, Claude Code, and Codex CLI (skipping any that
# are already installed), pulls the workshop database via Git LFS if needed,
# and runs the same data smoke test the Codespaces devcontainer runs.
# It does NOT log you into Claude/Codex — that's an interactive step you run
# yourself afterwards (see the banner this script prints at the end).
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_ROOT"

bold() { printf '\033[1m%s\033[0m\n' "$1"; }
step() { printf '\n== %s ==\n' "$1"; }
ok()   { printf '  ok: %s\n' "$1"; }
warn() { printf '  warning: %s\n' "$1"; }
fail() { printf '\nERROR: %s\n' "$1" >&2; exit 1; }

case "$(uname -s)" in
  Linux*|Darwin*) : ;;
  *) fail "This script needs a Unix shell (Linux, macOS, or WSL2 on Windows). Plain Windows cmd/PowerShell isn't supported — see WORKSHOP_SETUP_GUIDE_LOCAL.md, or use WORKSHOP_SETUP_GUIDE_CODESPACES.md instead." ;;
esac

step "Checking prerequisites"

command -v git >/dev/null 2>&1 || fail "git is not installed. Install it first: https://git-scm.com/downloads"
ok "git found ($(git --version))"

command -v curl >/dev/null 2>&1 || fail "curl is not installed. Install it first (e.g. 'sudo apt install curl' or 'brew install curl')."
ok "curl found"

if ! git lfs version >/dev/null 2>&1; then
  fail "git-lfs is not installed. Install it first (macOS: 'brew install git-lfs', Ubuntu/Debian: 'sudo apt install git-lfs'), then run: git lfs install
Then re-run this script."
fi
ok "git-lfs found ($(git lfs version))"

if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
  fail "Node.js + npm are required to install Claude Code. Install Node.js (includes npm) from https://nodejs.org, then re-run this script."
fi
ok "node found ($(node --version)), npm found ($(npm --version))"

step "Pulling workshop data (Git LFS)"

git lfs pull
if [ ! -f "data/workshop.duckdb" ]; then
  fail "data/workshop.duckdb is still missing after 'git lfs pull'. Confirm you're inside a clone of the workshop repo and that Git LFS is set up correctly."
fi
ok "data/workshop.duckdb present"

step "DuckDB CLI"

if command -v duckdb >/dev/null 2>&1; then
  ok "already installed ($(duckdb --version))"
else
  curl -fsSL https://install.duckdb.org | sh
  export PATH="$HOME/.duckdb/cli/latest:$HOME/.local/bin:$PATH"
  if ! command -v duckdb >/dev/null 2>&1; then
    fail "DuckDB CLI installed but not found on PATH. Open a new terminal and re-run this script, or add \$HOME/.local/bin to your PATH manually."
  fi
  ok "installed ($(duckdb --version))"
fi

step "Claude Code CLI"

if command -v claude >/dev/null 2>&1; then
  ok "already installed ($(claude --version))"
else
  npm install -g @anthropic-ai/claude-code
  export PATH="$HOME/.local/bin:$PATH"
  command -v claude >/dev/null 2>&1 || warn "installed via npm but 'claude' isn't on PATH yet — open a new terminal to pick it up."
fi

step "Codex CLI"

if command -v codex >/dev/null 2>&1; then
  ok "already installed ($(codex --version))"
else
  curl -fsSL https://chatgpt.com/codex/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
  command -v codex >/dev/null 2>&1 || warn "installed but 'codex' isn't on PATH yet — open a new terminal to pick it up."
fi

step "Data smoke test"

ROW_COUNT="$(duckdb data/workshop.duckdb -csv -noheader -c "SELECT count(*) FROM transactions;")"
echo "transactions table has ${ROW_COUNT} rows."
[ "$ROW_COUNT" -ge 1 ] || fail "transactions table is empty — data did not load correctly."
ok "smoke test passed"

cat <<'BANNER'

========================================================
 Setup complete! Next steps:

 1. Authenticate (one-time, interactive, opens a browser):
      claude
      codex

 2. Skim BANK_DATASET_SCHEMA.md to see what's in the dataset.

 3. Follow exercises.md to start asking questions.
========================================================
BANNER
