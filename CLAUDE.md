# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A half-day workshop that teaches participants to build a Claude Skill / Codex Skill turning plain-language questions into SQL, run live against a banking transactions dataset in DuckDB (`data/workshop.duckdb`, ~5.87M rows across 10 tables, tracked via Git LFS). There is no application code, build step, or test suite — the repo is workshop content: a devcontainer environment, a data dictionary, a worked-example skill, and setup/reference docs. All documentation content is written in Vietnamese (translated from an original English version); code, commands, file paths, and data values are left untouched — see "Vietnamese content, English data" below.

## Commands

Query the workshop database directly:
```bash
duckdb data/workshop.duckdb -c "SELECT ..."
```

Pull the LFS-tracked database file if it's missing or a stub pointer (`ls -la data/workshop.duckdb` should show ~75MB, not a few hundred bytes):
```bash
git lfs pull
```

Reproduce the full participant environment setup outside Codespaces (installs DuckDB CLI, Claude Code, Codex CLI, then smoke-tests the data):
```bash
bash .devcontainer/postCreate.sh
```

There is no lint/build/test command — changes are validated by actually asking the `sql-helper` skill a question (e.g. via `claude` or `codex` in the repo root) and confirming it grounds itself in `SCHEMA.md`, shows its SQL, and returns correct numbers. `docs/setup/WORKSHOP_SETUP_GUIDE_LOCAL.md` and `docs/setup/WORKSHOP_SETUP_GUIDE_CODESPACES.md` document this verification flow step by step.

## Architecture

**`SCHEMA.md`** is the single source of truth for the database: every table, column, type, and allowed value. Both the `sql-helper` skill and any ad-hoc SQL work in this repo must ground themselves in it — never invent a column/table name not listed there.

**Skills mirroring**: `.claude/skills/sql-helper/SKILL.md` is the real file; `.codex/skills/sql-helper/SKILL.md` is a symlink to it (`../../../.claude/skills/sql-helper/SKILL.md`), so Claude Code and Codex CLI read identical instructions. Edit only the `.claude` copy — the symlink keeps Codex in sync automatically. `templates/skill-template/SKILL.md` is the blank scaffold participants copy to build their own skill (frontmatter + `TODO` sections), following the same mirroring pattern into a new `.claude/skills/<name>/` and `.codex/skills/<name>/`.

**`docs/` is split by audience/purpose**, not by file type:
- `docs/setup/` — organizer-facing setup plan and step-by-step guides (`WORKSHOP_SETUP_PLAN.md` is the rationale doc everything else links back to; `WORKSHOP_SETUP_GUIDE_LOCAL.md` and `WORKSHOP_SETUP_GUIDE_CODESPACES.md` are dry-run verification checklists for the two ways to run the workshop; `Iteration_0_LocalTesting.md` is the Docker/devcontainer-parity local test).
- `docs/reference/` — material used live during/around the session (`DAY_OF_CHECKLIST.md`, `FACILITATOR_TROUBLESHOOTING.md`, deliberately not linked from the participant-facing README).
- `README.md`, `SCHEMA.md`, `exercises.md` stay in the repo root because `SKILL.md`, `postAttach.sh`, and the setup guides all reference them by that bare path.

These docs cross-reference each other by relative path (e.g. `docs/setup/*.md` guides link sideways to `../reference/*.md`). When moving or renaming any `.md` file, grep the whole repo for its filename and fix every reference — nothing enforces these links automatically.

**Devcontainer / `postCreate.sh`** installs the DuckDB CLI, Claude Code, and Codex CLI, then runs a `SELECT count(*) FROM transactions` smoke test that fails the container build loudly if the LFS pull didn't land real data. It has a musl (Alpine) fallback path: since the official DuckDB CLI binary is glibc-linked and won't run under musl, it installs the `duckdb` Python package instead and installs `.devcontainer/duckdb_shim.py` as a CLI-compatible `duckdb` shim on `PATH` (supports `duckdb <db> -c "<SQL>"`, `-csv`, `-json`, `-noheader`, and stdin). Any change to how the workshop invokes the `duckdb` CLI needs to stay compatible with this shim's supported flag subset.

## Vietnamese content, English data

All prose in every `.md` file (including `SKILL.md` frontmatter `description` and body instructions) is Vietnamese. Within that, keep the following in English exactly as-is, because they must match the real data/identifiers in `data/workshop.duckdb`:
- Table and column names, SQL keywords/types (`BIGINT`, `VARCHAR`, etc.), and code blocks.
- The literal example/enum values in `SCHEMA.md`'s tables (e.g. `Female`, `Salary Credit`, `Active`) — these are actual stored values in the dataset, not illustrative text, and translating them would make the schema doc inconsistent with what a query actually returns.
- Frontmatter `name:` fields in `SKILL.md` files (they're identifiers, not display text).
- File paths, filenames, and shell/SQL commands.
