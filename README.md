# CB_Txt2Sql — Text-to-SQL Skills Workshop

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/QuanPham99/CB_Txt2Sql)

A hands-on workshop where participants build a **Claude Skill / Codex Skill** that turns plain-English questions into SQL, run live against a banking transactions dataset in DuckDB.

## Before you arrive

- A GitHub account, logged in.
- A **Claude.ai account** with an active plan (Pro/Max), or a personal Anthropic API key.
- A **ChatGPT account** with Codex access (Plus/Pro/Business/Edu), or a personal OpenAI API key.
- A browser logged into both.

## Agenda (half-day)

1. **Open your Codespace** — click the badge above, or Code → Codespaces → Create codespace on main. Wait for the (pre-built) container to finish.
2. **Authenticate** — run `claude` and `codex` in the terminal and follow the login prompts.
3. **Read the worked example** — `.claude/skills/sql-helper/SKILL.md`, and skim `SCHEMA.md` for what's in the data.
4. **Ask questions in plain English** — work through `exercises.md` together.
5. **Build your own skill** — copy `templates/skill-template/SKILL.md`, write your own house rules, test it.
6. **Share out** — a few volunteers demo their skill live.

## What's in this repo

- `dataset/` — the raw Kaggle CSVs (git-ignored; not shipped in the Codespace).
- `data/workshop.duckdb` — the prepared, pre-loaded database participants actually query (tracked via Git LFS).
- `SCHEMA.md` — the data dictionary: every table, column, type, and example value.
- `exercises.md` — the guided workshop flow and example questions.
- `.claude/skills/sql-helper/`, `.codex/skills/sql-helper/` — the worked-example skill.
- `templates/skill-template/` — the blank scaffold for the "build your own skill" exercise.
- `.devcontainer/` — the one-click Codespaces environment (DuckDB CLI + Claude Code + Codex CLI + VS Code extensions, pre-installed).
- `WORKSHOP_SETUP_PLAN.md` — the full organizer setup plan.
- `DAY_OF_CHECKLIST.md` — organizer dry-run and day-of logistics checklist.
- `FACILITATOR_TROUBLESHOOTING.md` — facilitator-only troubleshooting doc.

## How it works

Participants open a pre-baked dev environment (DuckDB + data + Claude Code + Codex CLI), read a short data dictionary describing the dataset, and ask natural-language questions that get translated into SQL and executed against the data — no manual data exploration required.

See `WORKSHOP_SETUP_PLAN.md` for the complete setup and facilitation guide.
