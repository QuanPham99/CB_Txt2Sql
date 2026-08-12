# Workshop Exercises

Follow along live with the facilitator. You'll need `claude` or `codex` authenticated in your terminal (see the README) and `SCHEMA.md` open in a tab.

## Step 1 — Read the worked example

Open `.claude/skills/sql-helper/SKILL.md` (or `.codex/skills/sql-helper/SKILL.md` — same content). This is a **skill**: plain-English instructions the AI reads before answering, that tell it *how* to behave (ground itself in `SCHEMA.md`, always show its SQL, always `LIMIT 100`, etc.).

## Step 2 — Ask in plain English

Open a terminal in this repo and start `claude` or `codex`. Ask your first question:

> What were the top 5 transaction categories by total amount last quarter?

Watch it read the skill, write SQL against `data/workshop.duckdb`, run it, and explain the answer.

## Step 3 — Try these, in order

Each one adds a little more complexity than the last.

1. How many customers do we have, broken down by occupation?
2. What is the average account balance for each account type?
3. Which branch has processed the highest total transaction amount?
4. How many support tickets are still "Open," grouped by issue type?
5. What percentage of card transactions are flagged as fraud, by merchant category?
6. Which 10 customers have paid the most total interest on their loans?
7. For customers who joined in 2023, what's their average credit score compared to customers who joined in 2015?
8. Find accounts with a balance below their average monthly withdrawal amount over the last 6 months of data (these look like overdraft risks).

If an answer looks wrong, ask the AI to show you the SQL it ran — that's usually where the fix is obvious.

## Step 4 — Build your own skill

1. Copy the template: `templates/skill-template/SKILL.md` → a new folder `.claude/skills/<your-name>/SKILL.md`.
2. Mirror it to `.codex/skills/<your-name>/SKILL.md` (copy or symlink, same as the worked example).
3. Fill in the `TODO` sections with 3–5 instruction lines that encode a convention **you** choose. Some ideas:
   - "Always explain the query in one plain-English sentence before showing SQL."
   - "Always round currency to 2 decimals and add a $ or ₹ sign."
   - "Always sort results by date descending unless asked otherwise."
   - "Never return more than 20 rows without being asked."
   - "Always mention which table(s) the answer came from."

## Step 5 — Test it

Ask the same question from Step 2, or a new one. Confirm the AI's behavior now follows your rule. That's the "aha" moment: you wrote English, not code, and it changed how the AI behaves.

## Step 6 — Share out

A few volunteers show their skill file and a live question/answer to the group.
