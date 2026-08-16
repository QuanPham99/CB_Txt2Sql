# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A half-day workshop that teaches participants to build a Claude Skill / Codex Skill turning plain-language questions into SQL, run live against a banking transactions dataset in DuckDB (`data/workshop.duckdb`, ~5.87M rows across 10 tables, tracked via Git LFS). A second, independent preloaded dataset (`data/tech_salary.duckdb`, Kaggle tech-salary data) powers a short optional wrap-up exercise, and an optional local-only track (`my-data/` + `load_custom_data.sh`) lets participants load their own CSV files into a third, git-ignored database (`data/custom.duckdb`) and build a skill against it. There is no application code, build step, or test suite — the repo is workshop content: a devcontainer environment, data dictionaries, worked-example skills, and setup/reference docs. All documentation content is written in Vietnamese (translated from an original English version); code, commands, file paths, and data values are left untouched — see "Vietnamese content, English data" below.

## Commands

Query the workshop database directly:
```bash
duckdb data/workshop.duckdb -c "SELECT ..."
```

Pull the LFS-tracked database file if it's missing or a stub pointer (`ls -la data/workshop.duckdb` should show ~75MB, not a few hundred bytes):
```bash
git lfs pull
```

Reproduce the full participant environment setup inside the devcontainer (installs DuckDB CLI, Claude Code, Codex CLI, then smoke-tests the data):
```bash
bash .devcontainer/postCreate.sh
```

Reproduce the same setup **outside** any devcontainer, directly on a host machine (checks `git`/`curl`/`node`/`git-lfs` prerequisites the base image would otherwise guarantee — fails with manual-install instructions if missing, does not auto-install them — then does the same install + `git lfs pull` + smoke test for both databases):
```bash
./setup.sh
```

Organizer-only: rebuild the second dataset from raw CSVs dropped in `tech_salary_dataset/` (git-ignored):
```bash
./scripts/build_tech_salary_db.sh
```

Participant-facing, local-only: load CSV files dropped in `my-data/` (git-ignored) into `data/custom.duckdb`:
```bash
./load_custom_data.sh
```

There is no lint/build/test command — changes are validated by actually asking the `sql-helper` skill a question (e.g. via `claude` or `codex` in the repo root) and confirming it picks the correct schema doc under `schemas/` for the question asked, shows its SQL, and returns correct numbers. `docs/setup/WORKSHOP_SETUP_GUIDE_LOCAL.md` and `docs/setup/WORKSHOP_SETUP_GUIDE_CODESPACES.md` document this verification flow step by step.

## Architecture

For a full system-level walkthrough (build-time vs. run-time pipelines, query lifecycle, component map, design-tradeoff rationale) see `docs/architecture/ARCHITECTURE.md` — read it before making any structural change to the devcontainer, skill mirroring, or data pipeline. The summary below covers what's needed for day-to-day edits.

**`schemas/`** holds one hand-authored data dictionary per DuckDB database — `schemas/BANK_DATASET_SCHEMA.md` for `data/workshop.duckdb`, `schemas/TECH_SALARY_DATASET_SCHEMA.md` for `data/tech_salary.duckdb`. Each is the single source of truth for its database: every table, column, type, and allowed value. The `sql-helper` skill and any ad-hoc SQL work in this repo must ground themselves in the matching file — never invent a column/table name not listed there. The skill is instructed to trust these static files rather than introspect a database live (`DESCRIBE`/`PRAGMA`), so if a schema changes, the matching file must be updated by hand to match. Every schema doc opens with a "File cơ sở dữ liệu: `data/....duckdb`" line stating exactly which database it documents — `sql-helper` reads that line (rather than hardcoding a mapping) so a new schema file dropped into `schemas/` is picked up without editing the skill.

**`sql-helper` is dataset-agnostic, not banking-specific.** `.claude/skills/sql-helper/SKILL.md` first decides which database a question is about (by scanning `schemas/` and matching the question's topic against each schema's opening description), then grounds itself in that one schema doc and queries that one `.duckdb` file. It never joins or attaches across the two `.duckdb` files — they share no keys — and asks the user to disambiguate rather than guessing when a question could plausibly belong to more than one dataset. Any new dataset added to the workshop only needs a `data/<name>.duckdb` file plus a `schemas/<NAME>_SCHEMA.md` doc with that opening "File cơ sở dữ liệu" line; the skill does not need to change.

**`dataset/` vs `data/`**: `dataset/*.csv` is the original Kaggle export used only to build the database once (git-ignored, never present at container runtime). `data/workshop.duckdb` is the prebuilt, LFS-tracked database participants actually query — the container never regenerates it from the CSVs.

**Second dataset pipeline (tech-salary)**: `tech_salary_dataset/*.csv` (git-ignored, organizer-only input) → `scripts/build_tech_salary_db.sh` (organizer-only, fail-fast on any malformed CSV, always rebuilds from scratch) → `data/tech_salary.duckdb` (LFS-tracked, already covered by the existing `data/*.duckdb` `.gitattributes` pattern) → hand-authored `schemas/TECH_SALARY_DATASET_SCHEMA.md`. Fully independent of the banking pipeline — no shared tables, no cross-dataset joins expected. `postCreate.sh` and `setup.sh` both smoke-test it the same way they smoke-test `workshop.duckdb` (generically, via `information_schema.tables`, since its table names aren't hardcoded anywhere). `sql-helper` itself already routes between the two datasets (see above); the optional wrap-up exercise (`exercises.md`, last section) has participants add that same routing to their *own* skill (built in the earlier exercise, still single-dataset at that point) in place, rather than build a second skill — there is deliberately no second worked-example skill folder.

**Local custom-data pipeline**: `my-data/*.csv` (git-ignored, participant-owned) → `load_custom_data.sh` (participant-facing, CSV-only, always rebuilds `data/custom.duckdb` from scratch, per-file error isolation) → `data/custom.duckdb` (git-ignored, never committed — distinct from the two datasets above, which are LFS-tracked). `templates/custom-data-skill-template/SKILL.md` is the matching blank scaffold, deliberately without a schema doc to reference — participants explore their own schema via `.tables`/`DESCRIBE` and write it into their own SKILL.md by hand. Excel/.xlsx is intentionally out of scope here (handled by a separate "Claude for Excel" product, introduced outside this repo). Local install for this track is a manual, human-walked-through guide (`docs/setup/WORKSHOP_SETUP_GUIDE_LOCAL.md`, sections 0b/9, paired with a facilitator runbook in `docs/reference/FACILITATOR_TROUBLESHOOTING.md`) rather than an automated installer script — there is no `setup.ps1` or auto-installing prerequisite logic anywhere in this repo.

**Skills mirroring**: `.claude/skills/sql-helper/SKILL.md` is the real file; `.codex/skills/sql-helper/SKILL.md` is a symlink to it (`../../../.claude/skills/sql-helper/SKILL.md`), so Claude Code and Codex CLI read identical instructions. Edit only the `.claude` copy — the symlink keeps Codex in sync automatically. `templates/skill-template/SKILL.md` is the blank scaffold participants copy to build their own skill (frontmatter + `TODO` sections, grounded in `schemas/BANK_DATASET_SCHEMA.md` only — single-dataset on purpose, since the wrap-up exercise has participants add multi-dataset routing themselves), following the same mirroring pattern into a new `.claude/skills/<name>/` and `.codex/skills/<name>/`.

**`docs/` is split by audience/purpose**, not by file type:
- `docs/setup/` — organizer-facing setup plan and step-by-step guides (`WORKSHOP_SETUP_PLAN.md` is the rationale doc everything else links back to; `WORKSHOP_SETUP_GUIDE_LOCAL.md` and `WORKSHOP_SETUP_GUIDE_CODESPACES.md` are dry-run verification checklists for the two ways to run the workshop; `Iteration_0_LocalTesting.md` is the Docker/devcontainer-parity local test).
- `docs/reference/` — material used live during/around the session (`DAY_OF_CHECKLIST.md`, `FACILITATOR_TROUBLESHOOTING.md`, deliberately not linked from the participant-facing README; `exercises_answer_key.ipynb` holds the worked answers to `exercises.md`).
- `docs/architecture/` — `ARCHITECTURE.md`, the system-level deep dive referenced above.
- `README.md`, `exercises.md` stay in the repo root because `SKILL.md`, `postAttach.sh`, and the setup guides all reference them by that bare path.
- `schemas/` holds the hand-authored data dictionaries (`BANK_DATASET_SCHEMA.md`, `TECH_SALARY_DATASET_SCHEMA.md`) — kept in their own top-level folder, not under `docs/`, because they're read by `sql-helper` itself at answer time (not just by humans) and are meant to grow by simply adding a new file, not by editing the audience-organized `docs/` tree.

**No SQL validation layer.** The model shells out to the `duckdb` CLI with whatever SQL it generates — there's no allowlist, no read-only enforcement, no query sanitization at the application level. The rules in `SKILL.md` (show the SQL, prefer aggregation, `LIMIT 100`, ground in the schema) are behavioral guardrails for the model, not technical safeguards. Data safety instead relies on the dataset being synthetic/non-sensitive and each participant only having access to their own container.

These docs cross-reference each other by relative path (e.g. `docs/setup/*.md` guides link sideways to `../reference/*.md`). When moving or renaming any `.md` file, grep the whole repo for its filename and fix every reference — nothing enforces these links automatically.

**Devcontainer / `postCreate.sh`** installs the DuckDB CLI, Claude Code, and Codex CLI, then runs two smoke tests that fail the container build loudly if either LFS pull didn't land real data: `SELECT count(*) FROM transactions` against `data/workshop.duckdb`, and a generic `information_schema.tables`-driven check (table names unknown in advance) against `data/tech_salary.duckdb`. It has a musl (Alpine) fallback path: since the official DuckDB CLI binary is glibc-linked and won't run under musl, it installs the `duckdb` Python package instead and installs `.devcontainer/duckdb_shim.py` as a CLI-compatible `duckdb` shim on `PATH` (supports `duckdb <db> -c "<SQL>"`, `-csv`, `-json`, `-noheader`, and stdin). Any change to how the workshop invokes the `duckdb` CLI needs to stay compatible with this shim's supported flag subset.

## Vietnamese content, English data

All prose in every `.md` file (including `SKILL.md` frontmatter `description` and body instructions) is Vietnamese. Within that, keep the following in English exactly as-is, because they must match the real data/identifiers in `data/workshop.duckdb`:
- Table and column names, SQL keywords/types (`BIGINT`, `VARCHAR`, etc.), and code blocks.
- The literal example/enum values in `schemas/BANK_DATASET_SCHEMA.md`'s tables (e.g. `Female`, `Salary Credit`, `Active`) — these are actual stored values in the dataset, not illustrative text, and translating them would make the schema doc inconsistent with what a query actually returns.
- Frontmatter `name:` fields in `SKILL.md` files (they're identifiers, not display text).
- File paths, filenames, and shell/SQL commands.

This extends to script console output, with one deliberate split: `load_custom_data.sh` is fully Vietnamese (participants run it directly and read its output with no assistant necessarily present). `scripts/build_tech_salary_db.sh` stays fully English (organizer-only, never run by a participant). `setup.sh` and `postCreate.sh` are pre-existing English-language scripts (their existing lines are untouched), but new guidance banners added to them (e.g. `setup.sh`'s extended completion banner) are Vietnamese — so those two files intentionally mix English technical/diagnostic lines with Vietnamese "what to do next" lines.
