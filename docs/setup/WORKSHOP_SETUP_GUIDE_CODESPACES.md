# Workshop Setup Guide — Test via GitHub Codespaces

A practical, step-by-step walkthrough for spinning up **this exact repo** in a real GitHub Codespace and confirming the whole workshop works end to end — before you point 20–50 participants at it.

This is the "real environment" companion to `WORKSHOP_SETUP_GUIDE_LOCAL.md` and `Iteration_0_LocalTesting.md` (which run the workshop on your own machine to catch script/skill bugs fast, without needing GitHub at all). Codespaces-specific things — OAuth redirects, Git LFS pulls over the network, prebuilds, spending limits — can *only* be verified here, not locally. Do a local pass first if you haven't; then do this one.

> Repo: `QuanPham99/CB_Txt2Sql` (`origin` remote, `main` branch — confirmed pushed and up to date as of this guide).

---

## 0. Prerequisites (organizer)

- [ ] A GitHub account with access to `QuanPham99/CB_Txt2Sql` (owner access if you'll be changing repo/Codespaces settings).
- [ ] A **Claude.ai account** with an active plan (Pro/Max), or a personal Anthropic API key.
- [ ] A **ChatGPT account** with Codex access (Plus/Pro/Business/Edu), or a personal OpenAI API key.
- [ ] `data/workshop.duckdb` is tracked via Git LFS and pushed to `origin/main` (`git lfs ls-files` should list it; confirmed present locally at ~75MB).

---

## 1. Open a Codespace exactly as a participant would

Don't reuse an existing dev Codespace — old cached layers can hide a broken `postCreateCommand`.

1. Go to `https://github.com/QuanPham99/CB_Txt2Sql`.
2. **Code → Codespaces → Create codespace on main** (or click the "Open in GitHub Codespaces" badge in `README.md`).
3. Watch the creation log (Codespaces → your Codespace → "..." → **View creation log**). You're watching `.devcontainer/postCreate.sh` run live:
   - Installs the DuckDB CLI
   - `npm install -g @anthropic-ai/claude-code`
   - Installs the Codex CLI
   - Runs the data smoke test — it should print `Smoke test: transactions table has 2000000 rows.` and then `== Setup complete ==`
4. **If the log shows an error and the build fails**, stop here and fix it (see `../reference/FACILITATOR_TROUBLESHOOTING.md` → "`data/workshop.duckdb` missing or empty") before doing anything else — a broken `postCreateCommand` fails identically for every participant.
5. Once it opens, you should see the `postAttach.sh` welcome banner printed in the terminal:
   ```
   ========================================================
    Welcome to the Text-to-SQL Skills Workshop!
    1. Read SCHEMA.md to see what's in the dataset.
    2. Authenticate:  claude   /   codex
    3. Follow exercises.md to get started.
   ========================================================
   ```

**Time this.** Note the wall-clock time from clicking "Create codespace" to the banner appearing — you'll want this number for the day-of agenda (see `../reference/DAY_OF_CHECKLIST.md`).

---

## 2. Verify the data landed correctly

In the integrated terminal:

```bash
duckdb data/workshop.duckdb -c "SELECT count(*) FROM transactions;"
```

Expect `2000000`. If it's `0`, an error, or the file looks tiny (a few hundred bytes = an unresolved LFS pointer, not real data), run:

```bash
git lfs pull
bash .devcontainer/postCreate.sh
```

and re-check. This is the one failure mode that's easy to hit in Codespaces but invisible locally if you already had the file cached — treat it as the primary thing this guide exists to catch.

---

## 3. Authenticate both CLIs

```bash
claude
```
Follow the printed login URL, sign in with your Claude.ai account (or paste a personal Anthropic API key).

```bash
codex
```
Follow the printed URL / "Sign in with ChatGPT" prompt (or paste a personal OpenAI API key).

**What to watch for:** this is the step most likely to behave differently than your local Docker test — Codespaces' forwarded-browser OAuth path is different from `localhost`. If the browser bounces back without completing the login:
- Try the device-code flow if the CLI offers one.
- Check whether your GitHub/Claude/OpenAI account is behind org SSO — try a personal account instead.
- Check the **Ports** tab in VS Code — temporarily set the forwarded auth port's visibility to "Public," retry, then set it back.

(Full detail in `../reference/FACILITATOR_TROUBLESHOOTING.md`.)

---

## 4. Confirm the VS Code extensions loaded

Check the Extensions sidebar (or just try using them):
- [ ] Claude Code extension (`anthropic.claude-code`)
- [ ] Codex extension (`openai.chatgpt`)
- [ ] `evidence.sqltools-duckdb-driver` + `mtxr.sqltools` — lets you browse `data/workshop.duckdb` tables from the sidebar

Extensions install asynchronously after the container reports "ready." If one's missing, wait ~30s and reload the window (`Cmd/Ctrl+Shift+P` → "Developer: Reload Window") before assuming it failed.

---

## 5. Skim the data dictionary

```bash
code SCHEMA.md   # or just open it in the editor
```

This is the only "data understanding" step a participant needs — confirm it still accurately describes `data/workshop.duckdb` (table name, row count, columns, quirks). If you've touched the dataset since this was written, update `SCHEMA.md` now.

---

## 6. Test the worked-example skill

Open `.claude/skills/sql-helper/SKILL.md` (and confirm `.codex/skills/sql-helper/SKILL.md` mirrors it) so you know what behavior you're checking for. Then, in `claude` (and again in `codex`), ask:

> What were the top 5 transaction categories by total amount last quarter?

Confirm it:
- [ ] Grounds itself in `SCHEMA.md` (doesn't invent column names)
- [ ] Shows the SQL it ran
- [ ] Applies the house rules from `SKILL.md` (e.g. `LIMIT 100` on raw rows, rounded currency)
- [ ] Actually queries `data/workshop.duckdb` and returns real numbers

---

## 7. Work through the exercises

```bash
code exercises.md
```

Run through all the example questions yourself, in order, in this real Codespace. If any answer looks wrong or the model invents a column/table, fix `SKILL.md` or `SCHEMA.md` now — not during the live workshop.

---

## 8. Build a throwaway custom skill

This is Step 3–4 of the actual workshop flow — try it yourself first:

1. Copy `templates/skill-template/SKILL.md` into a new folder, e.g. `.claude/skills/scratch-test/`.
2. Fill in 2–3 house rules (e.g. "always explain the query in one sentence").
3. Ask a question again and confirm the behavior visibly changed.
4. Delete the scratch folder when done (don't commit it).

If this is confusing or fiddly for you, it'll be confusing for a non-technical participant — simplify `templates/skill-template/SKILL.md` if so.

---

## 9. Tear down

Codespaces auto-stop after a period of inactivity, but to clean up explicitly:

**GitHub → Settings → Codespaces**, or from the repo: **Code → Codespaces → "..." → Delete**.

You're not charged for a stopped Codespace's compute, only storage — delete test Codespaces you don't need anymore to avoid clutter.

---

## 10. Before opening this up to real participants

Once steps 1–9 all pass cleanly in a fresh Codespace:

- [ ] Enable **Codespaces prebuilds** for `main` (repo → Settings → Codespaces → Set up prebuild) so participants get a warm container instead of a multi-minute cold build. Do this a day or two ahead, matched to where most participants are.
- [ ] Set a **Codespaces spending limit** sized for the expected headcount × half-day usage (org/repo → Settings → Billing → Codespaces spending limit).
- [ ] Confirm Codespaces is enabled for the account types your participants will actually use — personal accounts work out of the box; work/enterprise accounts may need an org admin to turn it on. Flag this in pre-workshop comms if relevant.
- [ ] Record the ~2-minute backup screen capture of this golden path in case live demos fail on the day.
- [ ] Hand off to `../reference/DAY_OF_CHECKLIST.md` for the rest of the pre-workshop and day-of logistics.

---

## Quick reference — what lives where

| File | Purpose |
|---|---|
| `README.md` | Participant-facing entry point, one-click Codespaces badge |
| `SCHEMA.md` | Data dictionary the AI grounds itself in |
| `exercises.md` | Guided in-workshop flow + example questions |
| `.claude/skills/sql-helper/`, `.codex/skills/sql-helper/` | Worked-example skill (mirrored) |
| `templates/skill-template/` | Blank scaffold for "build your own skill" |
| `.devcontainer/` | The Codespaces environment definition |
| `data/workshop.duckdb` | Pre-loaded DB (Git LFS) — the only data participants touch |
| `docs/setup/WORKSHOP_SETUP_PLAN.md` | Full organizer background/rationale for all of the above |
| `docs/reference/DAY_OF_CHECKLIST.md` | Pre-workshop and day-of logistics checklist |
| `docs/reference/FACILITATOR_TROUBLESHOOTING.md` | Live-session troubleshooting (facilitator-only) |
| `docs/setup/WORKSHOP_SETUP_GUIDE_LOCAL.md` | Run the workshop directly on your own machine, no GitHub/Codespaces needed |
| `docs/setup/Iteration_0_LocalTesting.md` | The Docker/devcontainer-based local equivalent of this guide |
