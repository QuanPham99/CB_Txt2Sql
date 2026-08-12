# Facilitator Troubleshooting (not for participants)

Keep this open on a second screen during the workshop. Not linked from the README on purpose — participants shouldn't need it.

## Codespace stuck building / very slow
- Confirm prebuilds are enabled and green for the default branch (repo → Settings → Codespaces → Prebuild configurations). A cold build without a prebuild can take several minutes and will look "stuck" to a participant.
- Ask them to cancel and re-open: **Code → Codespaces → "..." → Rebuild container**. If that fails twice, have them delete the Codespace and create a fresh one — old cached layers occasionally corrupt.
- If it's happening to many people at once, it's likely simultaneous cold starts queuing on GitHub's side — stagger the "everyone click now" instruction next time (see the day-of checklist).

## `claude` or `codex` OAuth login loop (browser bounces back without completing)
- Have them try the device-code flow instead of the browser popup, if the CLI offers one (`claude login --no-browser` / equivalent Codex flag) — this is more reliable inside Codespaces' forwarded-browser setup.
- Check if their GitHub/Claude/OpenAI account is behind org SSO — SSO-gated accounts sometimes block the OAuth redirect used by CLIs. Ask them to try a personal (non-work) account if they have one, or fall back to an API key.
- Codespaces port forwarding can occasionally block the callback — try switching the forwarded port's visibility to "Public" temporarily (Ports tab in VS Code), retry, then set it back.

## `data/workshop.duckdb` missing or empty
- `postCreateCommand` should have caught this and failed loudly in the Codespace creation log — check that log first (Codespaces → the Codespace → "..." → "View creation log").
- Likely cause: Git LFS didn't pull. Run manually in the terminal: `git lfs pull` then re-run `bash .devcontainer/postCreate.sh`.
- Sanity check row counts: `duckdb data/workshop.duckdb -c "SELECT count(*) FROM transactions;"` should return 2,000,000. If it returns 0 or errors "no such table," the file is a stub/pointer, not the real data — that's the LFS symptom above.

## Rate limits / "please wait and try again" from Claude or ChatGPT
- Free/lower tiers can hit rate limits under a room of 20–50 people all querying at once. Have the affected participant pair up with a neighbor for a few minutes, or switch to watching the shared demo screen.
- Keep the 2-minute backup screen recording of the golden path ready (see Part 3 of `WORKSHOP_SETUP_PLAN.md`) in case this becomes widespread — play it while things recover rather than stalling the room.

## VS Code extension didn't load (Claude Code / Codex sidebar missing)
- Extensions install async after the container reports "ready" — ask them to wait ~30s and reload the window (`Cmd/Ctrl+Shift+P` → "Developer: Reload Window").
- If still missing, check the Extensions sidebar for an install error, then install manually from the marketplace as a fallback (extension IDs are in `.devcontainer/devcontainer.json`).

## General fallback
If more than 2–3 people hit the same issue at once, stop individual troubleshooting and address it to the whole room — it's probably systemic (prebuild not warm, org SSO blocking everyone from one company, etc.), not per-person.
