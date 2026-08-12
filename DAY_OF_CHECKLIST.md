# Organizer Checklist — Dry Run & Day-Of Logistics

Companion to Part 3 of `WORKSHOP_SETUP_PLAN.md`. Items marked **[MANUAL]** happen on GitHub's website or in a live session and can't be done from this repo — they're listed here so nothing gets missed.

## A few days before

- [ ] **[MANUAL]** Enable Codespaces prebuilds for the default branch: repo → Settings → Codespaces → Set up prebuild. Match the prebuild region(s) to where most participants are.
- [ ] **[MANUAL]** Set a Codespaces spending limit sized for 20–50 people × half-day usage: org/repo → Settings → Billing → Codespaces spending limit.
- [ ] **[MANUAL]** Confirm Codespaces is enabled for the account types your participants will use — personal GitHub accounts work out of the box; work/enterprise accounts may need an org admin to enable it. Flag this in pre-workshop comms if any participants are on work accounts.
- [ ] **[MANUAL]** Create a fresh Codespace from the repo exactly as a participant would (don't reuse your dev Codespace). Time the full flow end-to-end: container start → `claude`/`codex` login → first successful query. Fix anything slow or confusing before moving on.
- [ ] Confirm both CLIs authenticate cleanly via OAuth with a personal/test account. If possible, test on both Mac and Windows browsers — WSL/Windows sometimes hits different OAuth redirect behavior. See `FACILITATOR_TROUBLESHOOTING.md` if login loops.
- [ ] **[MANUAL]** Record a ~2-minute screen capture of the golden path (open Codespace → login → ask a question → get an answer) as a backup in case live demos or someone's network fails.
- [ ] **[MANUAL]** Send the pre-workshop email/Slack message with: repo link, "before you arrive" checklist (GitHub account ready; Claude.ai account with an active plan or API key; ChatGPT account with Codex access or API key; browser logged into both), and expected Codespace build time.

## Day of

- [ ] **[MANUAL]** Stagger "Open in Codespaces" clicks by a minute or two across the room/call — 50 simultaneous cold starts can queue even with prebuilds warm. Split the agenda into "everyone open your Codespace now" and, a couple minutes later, "everyone log in now."
- [ ] Have `FACILITATOR_TROUBLESHOOTING.md` open on a second screen.
- [ ] Have the backup screen recording ready to play if live demos stall.

## Pre-workshop verification (do this after the dry run above)

- [ ] Fresh Codespace confirms `SELECT count(*) FROM transactions;` in `data/workshop.duckdb` returns 2,000,000 (the `postCreateCommand` smoke test should also catch this automatically in the creation log).
- [ ] Both `claude` and `codex` authenticate via OAuth.
- [ ] Both VS Code extensions (Claude Code, Codex) load in the Codespace.
- [ ] The worked-example skill (`.claude/skills/sql-helper/SKILL.md`) visibly changes model behavior when tested with a sample question from `exercises.md`.
- [ ] Cold-open-to-first-query timing fits comfortably inside the half-day agenda's opening block.
