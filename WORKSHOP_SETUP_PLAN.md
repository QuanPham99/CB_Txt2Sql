# Text-to-SQL Skills Workshop — Setup Plan

## Context

The goal is a half-day workshop (20–50 participants, mixed tech / non-tech, single unified track) where everyone learns to build a **Claude Skill / Codex Skill** that turns plain-English questions into SQL run against DuckDB, using the Kaggle "Banking Transactions" dataset as the shared playground. Setup friction is the enemy — especially for non-tech participants — so the whole environment (DuckDB + data + Claude Code + Codex CLI + VS Code extensions) ships pre-baked in a GitHub Codespaces devcontainer that opens with one click.

Per your answers: participants authenticate with their **own** Claude / ChatGPT accounts (no pooled API keys to manage), and you want the **database and a plain-English schema description fully prepared by you in advance**, so participants (and their AI) never have to explore raw data — they just read a short data dictionary and start asking questions.

Note: I could not fetch the actual Kaggle page content from this environment (network blocked to kaggle.com), so I can't pre-fill the real column names here. Part 0 below is written so you do that inspection once, using DuckDB itself — it's fast and it doubles as your first sanity check that the data loads cleanly.

---

## Part 0 — Organizer: Prepare the data (do this first, before building the repo)

1. Download the CSV(s) from https://www.kaggle.com/datasets/vivekmali1436/banking-transactions-dataset (Kaggle web UI "Download" button, or `kaggle datasets download -d vivekmali1436/banking-transactions-dataset` if you have the `kaggle` CLI + API token set up).
2. Inspect it locally with DuckDB (install DuckDB CLI locally first — `curl https://install.duckdb.org | sh` on Mac/Linux, or `winget install DuckDB.cli` on Windows) so you know the real schema before anyone else touches it:
   ```sql
   duckdb
   CREATE TABLE transactions AS SELECT * FROM read_csv_auto('transactions.csv');
   DESCRIBE transactions;
   SUMMARIZE transactions;
   SELECT * FROM transactions LIMIT 20;
   ```
3. Decide on final table name(s) and, if needed, clean/rename columns to something workshop-friendly (snake_case, no ambiguous abbreviations). Persist the cleaned data as the DB you'll ship:
   ```sql
   COPY transactions TO 'workshop.duckdb'; -- or just keep building in a .duckdb file directly
   ```
4. Write a short **data dictionary** (this is the artifact participants and the AI will actually read — keep it under ~40 lines):
   - Table name(s), row count, date range covered
   - Each column: name, type, one-line meaning, example value
   - Any known quirks (nulls, currency units, PII-looking fields you've anonymized/dropped)
5. Save this as `SCHEMA.md` in the repo root — this becomes the single source of truth both facilitators and the AI models ground their answers in.

---

## Part 1 — Organizer: Repo & Codespaces setup

1. Create a new GitHub repo (e.g. `text2sql-skills-workshop`) — public or org-internal, whichever your participants can access.
2. Add the prepared `workshop.duckdb` (with data already loaded) to the repo, e.g. under `data/workshop.duckdb`. If it exceeds ~50MB, use Git LFS (`git lfs track "*.duckdb"`) — check the actual file size after Part 0; typical Kaggle CSVs of this kind are a few MB to low tens of MB, so LFS likely isn't needed, but verify.
3. Create `.devcontainer/devcontainer.json`:
   - Base image: `mcr.microsoft.com/devcontainers/base:ubuntu`
   - `features`: Node.js feature (needed for `npm install -g` of Claude Code)
   - `postCreateCommand` script that:
     - Installs DuckDB CLI (`curl https://install.duckdb.org | sh`)
     - Installs Claude Code: `npm install -g @anthropic-ai/claude-code`
     - Installs Codex CLI: `curl -fsSL https://chatgpt.com/codex/install.sh | sh`
     - Verifies `data/workshop.duckdb` exists and runs a quick `SELECT count(*)` as a smoke test, printed to the Codespace creation log
   - `customizations.vscode.extensions`: `anthropic.claude-code`, the official OpenAI Codex VS Code extension, and a DuckDB/SQL extension for browsing tables in the sidebar
   - `postAttachCommand` (optional): print a short "welcome" message pointing to `SCHEMA.md` and the exercises doc
4. Enable **Codespaces prebuilds** for the repo's default branch a day or two before the workshop, so all 20–50 participants get a warm, pre-built container instead of a multi-minute cold build during the session. Set the prebuild region(s) to match where most participants are.
5. Set an org-level (or repo-level) **Codespaces spending limit** appropriate for 20–50 people × half-day usage, and confirm Codespaces is enabled for everyone's account type (personal GitHub accounts work fine; work/enterprise accounts may need Codespaces enabled by their org admin — flag this in pre-workshop comms).
6. Since participants bring their own Claude/ChatGPT accounts, add a short note in the README on what they need ready *before* the workshop: a Claude.ai account with an active plan (or personal Anthropic API key) and a ChatGPT account with Codex access (Plus/Pro/Business/Edu, or a personal OpenAI API key) — see Part 4.

---

## Part 2 — Organizer: Workshop materials in the repo

1. `README.md` — one-click "Open in GitHub Codespaces" badge, agenda, and a link to `SCHEMA.md`.
2. `SCHEMA.md` — from Part 0.
3. A worked example skill, committed so participants can read it before writing their own. Since Codex CLI (2026) now reads the **same `SKILL.md` format** as Claude Code, write it once and reference it from both tool directories:
   - `.claude/skills/sql-helper/SKILL.md` — the real file
   - `.codex/skills/sql-helper/SKILL.md` — symlink (or copy) to the same content
   - Content: frontmatter with a trigger description ("query the transactions data", "text to SQL"), instructions to always query via DuckDB against `data/workshop.duckdb`, ground itself in `SCHEMA.md`, and follow house rules you choose to teach (e.g., always `LIMIT 100` unless asked otherwise, always show the SQL it ran, never invent column names not in `SCHEMA.md`).
4. `exercises.md` — the guided flow participants follow live (see Part 5), plus 5–8 example natural-language questions of increasing difficulty (e.g., "how many transactions happened last month" → "which account had the highest total outgoing transfers, broken down by month").
5. `templates/skill-template/SKILL.md` — a blank scaffold with placeholder frontmatter and `TODO` instruction sections for the "build your own skill" exercise.
6. A one-page **facilitator troubleshooting doc** (not in the participant-facing README) covering: Codespace stuck building → rebuild container; OAuth login loop → try device-code flow / check org SSO; DuckDB file missing → re-run postCreateCommand manually; rate limits → fall back to a shared demo screen.

---

## Part 3 — Organizer: Dry run & day-of logistics

1. A few days before: create a fresh Codespace from the repo exactly as a participant would (don't reuse your dev one), time the full flow end-to-end (container start → login → first successful query), and fix anything slow or confusing.
2. Confirm both CLIs authenticate cleanly with a personal/test account using the OAuth flow described in Part 4, on both Mac and Windows browsers if you can (WSL/Windows users sometimes hit different OAuth redirect behavior).
3. Prepare a backup plan: a recorded 2-minute screen capture of the golden path, in case live demos or someone's network fails.
4. Pre-workshop email/Slack to participants: link to the repo, the "before you arrive" checklist (GitHub account ready, Claude.ai/ChatGPT account with an active plan, browser logged into both), and expected Codespace build time.
5. Day-of: stagger "Open in Codespaces" clicks by a minute or two across the room/call if possible (50 simultaneous cold starts can queue even with prebuilds) — an easy way is to have the agenda naturally separate "everyone open your Codespace now" from "everyone log in now" by a couple of minutes.

---

## Part 4 — Participant: Setup (day of, minimal steps)

1. Have a GitHub account, logged in, in a browser.
2. Open the repo link the organizer shared → click **Code → Codespaces → Create codespace on main** (or the README's one-click badge).
3. Wait for the container to finish building (should be fast — it's prebuilt). VS Code opens in the browser (or desktop app if they chose that).
4. In the integrated terminal, authenticate each tool once:
   - `claude` → follow the printed URL, log in with your Claude.ai account (Pro/Max) or paste a personal API key if you have one instead.
   - `codex` → follow the printed URL / click "Sign in with ChatGPT" in the Codex sidebar icon, log in with your ChatGPT account (Plus/Pro/Business/Edu) or a personal OpenAI API key.
5. Sanity check the data is there:
   ```sql
   duckdb data/workshop.duckdb
   SELECT * FROM transactions LIMIT 5;
   ```
6. Open `SCHEMA.md` and skim it — that's all the "data understanding" needed before starting.

---

## Part 5 — Participant: Workshop flow (facilitator-led)

1. **Read together**: open the worked example at `.claude/skills/sql-helper/SKILL.md`, discuss what a skill is (instructions + grounding the AI reads before answering).
2. **Ask in plain English**: everyone types a natural-language question into `claude` or `codex` (e.g., "what were the top 5 transaction categories by total amount last quarter?") and watches the tool write + run SQL against `data/workshop.duckdb`, using the example skill.
3. **Build your own skill**: copy `templates/skill-template/SKILL.md` into a new folder under `.claude/skills/<their-name>/` (and mirror to `.codex/skills/`), write 3–5 instruction lines encoding a convention they choose (e.g., "always explain the query in one sentence," "always round currency to 2 decimals," "always sort by date descending by default").
4. **Test it**: ask the same or a new natural-language question and confirm the AI's answer now follows their custom rule — this is the "aha" moment for non-tech participants (they wrote something in English that changed the AI's behavior, no code).
5. **Share out**: a few volunteers show their skill and the question/answer live.

---

## Verification

- Before the workshop: create a Codespace from the repo as a fresh participant, confirm DuckDB has data (`SELECT count(*) FROM transactions`), both `claude` and `codex` authenticate via OAuth, both VS Code extensions load, and the worked-example skill visibly changes model behavior when tested with a sample question.
- Time the cold-open-to-first-query flow and make sure it fits comfortably inside the half-day agenda's opening block.
