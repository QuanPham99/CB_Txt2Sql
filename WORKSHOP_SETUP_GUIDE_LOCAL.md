# Workshop Setup Guide — Run Locally (no GitHub/Codespaces)

**Yes — this repo runs fine locally.** Nothing in the workshop actually depends on Codespaces; `.devcontainer/postCreate.sh` just does three things any Mac/Linux machine (or WSL on Windows) can do directly: install the DuckDB CLI, install the Claude Code and Codex CLIs, and confirm `data/workshop.duckdb` loaded. This guide does the same steps on your bare host, no container involved.

Two ways to run it locally — pick one:

| Approach | When to use it |
|---|---|
| **A. Direct on your host** (this guide) | Fastest way to try the workshop yourself or with a small in-person group sharing one machine. No Docker required. |
| **B. Via the devcontainer, in Docker** (`Iteration_0_LocalTesting.md`) | You're testing the *exact* environment participants will get in Codespaces — same base image, same `postCreate.sh`/`postAttach.sh`, isolated from your host. Use this before a real workshop to catch container-specific bugs. |

This guide covers **A**. If you want container parity instead, stop here and go to `Iteration_0_LocalTesting.md`.

> Repo: `QuanPham99/CB_Txt2Sql` (`origin` remote, `main` branch).

---

## 0. Prerequisites

- **Git** with **Git LFS** installed (`git lfs version` should succeed — `data/workshop.duckdb` is stored via LFS; without it you'll get a small pointer file instead of real data).
- **Node.js + npm** (`node --version`) — needed for `npm install -g @anthropic-ai/claude-code`.
- **curl**.
- macOS or Linux, or **WSL2** on Windows — `postCreate.sh`'s install commands are Bash/curl-based and assume a Unix shell. Plain Windows (cmd/PowerShell) is not a supported path here.
- A **Claude.ai account** with an active plan (Pro/Max), or a personal Anthropic API key.
- A **ChatGPT account** with Codex access (Plus/Pro/Business/Edu), or a personal OpenAI API key.

---

## 1. Clone the repo

```bash
git clone git@github.com:QuanPham99/CB_Txt2Sql.git
cd CB_Txt2Sql
```

If you don't have Git LFS installed yet, install it *before* cloning (or run `git lfs pull` right after):

```bash
git lfs install
git lfs pull
```

---

## 2. Confirm the data pulled correctly

```bash
ls -la data/workshop.duckdb
```

Expect a real file, ~75MB. If it's only a few hundred bytes, that's an unresolved LFS pointer — run `git lfs pull` again and re-check.

```bash
duckdb data/workshop.duckdb -c "SELECT count(*) FROM transactions;"
```

If you don't have the DuckDB CLI yet, install it now (this is the same command `postCreate.sh` runs):

```bash
curl -fsSL https://install.duckdb.org | sh
export PATH="$HOME/.duckdb/cli/latest:$PATH"
echo 'export PATH="$HOME/.duckdb/cli/latest:$PATH"' >> ~/.bashrc   # or ~/.zshrc
```

Expect `2000000`.

---

## 3. Install the CLIs

```bash
npm install -g @anthropic-ai/claude-code
```

```bash
curl -fsSL https://chatgpt.com/codex/install.sh | sh
export PATH="$HOME/.local/bin:$PATH"
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc   # or ~/.zshrc
```

Verify:

```bash
claude --version
codex --version
```

---

## 4. Authenticate both CLIs

From the repo root:

```bash
claude
```
Follow the printed login URL, sign in with your Claude.ai account (or paste a personal Anthropic API key).

```bash
codex
```
Follow the printed URL / "Sign in with ChatGPT" prompt (or paste a personal OpenAI API key).

Local OAuth on your own machine is usually the *smoothest* login path — no forwarded-port redirect quirks like Codespaces has. If either login loops, see the general OAuth advice in `FACILITATOR_TROUBLESHOOTING.md` (org SSO blocking the redirect is the most common cause, independent of Codespaces vs. local).

---

## 5. Skim the data dictionary

```bash
open SCHEMA.md   # or just open it in your editor
```

This is the only "data understanding" step needed before asking questions — confirm it still accurately describes `data/workshop.duckdb`.

---

## 6. Test the worked-example skill

Both `claude` and `codex` read skills relative to the current working directory, so make sure your terminal is inside the repo root before starting them. Then ask:

> What were the top 5 transaction categories by total amount last quarter?

Confirm it:
- [ ] Grounds itself in `SCHEMA.md` (doesn't invent column names)
- [ ] Shows the SQL it ran
- [ ] Applies the house rules from `.claude/skills/sql-helper/SKILL.md` (e.g. `LIMIT 100` on raw rows, rounded currency)
- [ ] Actually queries `data/workshop.duckdb` and returns real numbers

---

## 7. Work through the exercises

```bash
open exercises.md
```

Run through all the example questions yourself, in order. If any answer looks wrong or the model invents a column/table, fix `SKILL.md` or `SCHEMA.md` now.

---

## 8. Build a throwaway custom skill

1. Copy `templates/skill-template/SKILL.md` into a new folder, e.g. `.claude/skills/scratch-test/`.
2. Fill in 2–3 house rules.
3. Ask a question again and confirm the behavior visibly changed.
4. Delete the scratch folder when done (don't commit it).

---

## Running this with a small group, locally, without Codespaces

If you're testing with a few people in person rather than solo:

- Each person needs their own clone (Step 1) and their own `claude`/`codex` login (Step 4) — logins are per-account, not shared.
- There's no equivalent of Codespaces prebuilds here; each person's Steps 2–3 take as long as their network/npm install does. For a room bigger than a handful of people, Codespaces (`WORKSHOP_SETUP_GUIDE_CODESPACES.md`) is the better fit — it's what the "before you arrive" setup in the README and `WORKSHOP_SETUP_PLAN.md` are built around.

---

## Known local-only caveats

- `dataset/*.csv` (the raw Kaggle CSVs) are git-ignored — they're not needed at runtime, only `data/workshop.duckdb` matters. If you need to rebuild the `.duckdb` file from scratch, see Part 0 of `WORKSHOP_SETUP_PLAN.md`.
- Plain Windows (no WSL) isn't supported by this guide — `postCreate.sh`'s install commands are Bash-only. Windows participants should either use WSL2 locally or use Codespaces instead, which sidesteps the OS question entirely.
- This path doesn't exercise Codespaces-specific failure modes (OAuth-over-forwarded-port, LFS pull over GitHub's infrastructure, prebuild warmup, spending limits). If you're the organizer preparing for a real Codespaces-based workshop, still do a pass through `WORKSHOP_SETUP_GUIDE_CODESPACES.md` before the event — a clean local run does not guarantee a clean Codespaces run.

---

## Quick reference — what lives where

| File | Purpose |
|---|---|
| `README.md` | Participant-facing entry point, one-click Codespaces badge |
| `SCHEMA.md` | Data dictionary the AI grounds itself in |
| `exercises.md` | Guided in-workshop flow + example questions |
| `.claude/skills/sql-helper/`, `.codex/skills/sql-helper/` | Worked-example skill (mirrored) |
| `templates/skill-template/` | Blank scaffold for "build your own skill" |
| `data/workshop.duckdb` | Pre-loaded DB (Git LFS) — the only data participants touch |
| `WORKSHOP_SETUP_GUIDE_CODESPACES.md` | Same flow, run in a real GitHub Codespace |
| `Iteration_0_LocalTesting.md` | Container-parity local testing via Docker + devcontainer CLI |
| `WORKSHOP_SETUP_PLAN.md` | Full organizer background/rationale for all of the above |
| `DAY_OF_CHECKLIST.md` | Pre-workshop and day-of logistics checklist |
| `FACILITATOR_TROUBLESHOOTING.md` | Live-session troubleshooting (facilitator-only) |
