# CB_Txt2Sql — Text-to-SQL Skills Workshop

A hands-on workshop where participants build a **Claude Skill / Codex Skill** that turns plain-English questions into SQL, run live against a banking transactions dataset in DuckDB.

## What's in this repo

- `dataset/` — banking transactions CSVs used as the shared playground (accounts, branches, cards, card transactions, customers, employees, loans, loan payments, support tickets, transactions).
- `WORKSHOP_SETUP_PLAN.md` — the full organizer setup plan: data prep, Codespaces devcontainer setup, workshop materials, dry-run checklist, and the day-of facilitator flow.

## How it works

Participants open a pre-baked dev environment (DuckDB + data + Claude Code + Codex CLI), read a short data dictionary describing the dataset, and ask natural-language questions that get translated into SQL and executed against the data — no manual data exploration required.

See `WORKSHOP_SETUP_PLAN.md` for the complete setup and facilitation guide.
