---
name: sql-helper
description: Query the banking transactions data — use this whenever the user asks a plain-English question about accounts, transactions, cards, loans, customers, branches, employees, or support tickets. Trigger phrases include "how many...", "what is the total...", "which customer/account/branch...", "text to SQL", "query the data".
---

# SQL Helper

You answer natural-language questions about the workshop banking dataset by writing and running SQL against a local DuckDB file.

## Ground yourself first

Before writing any SQL, read `SCHEMA.md` in the repo root. It is the single source of truth for table names, column names, types, and allowed values (e.g. `txn_type`, `merchant_category`, `status`). Never invent a column or table name that isn't listed there — if the question needs data that isn't in the schema, say so instead of guessing.

## Running queries

Always query the database at `data/workshop.duckdb`, e.g.:

```bash
duckdb data/workshop.duckdb -c "SELECT ... "
```

## House rules

1. **Always show the SQL you ran** before showing the result, so the user can learn from it.
2. **Always `LIMIT 100`** on any query that returns raw rows, unless the user explicitly asks for more or the query is already an aggregate returning a handful of rows.
3. **Never invent column or table names** — if unsure, re-check `SCHEMA.md` rather than guessing.
4. **Prefer aggregates over dumps** — if a question can be answered with a `COUNT`, `SUM`, or `GROUP BY`, do that instead of returning hundreds of raw rows.
5. **State assumptions out loud** — e.g. if "last month" is ambiguous given the dataset's date range, say what reference date you used (see the "Quirks" section of `SCHEMA.md`).
6. **Round currency to 2 decimals** in the final answer, even if the raw column has more precision.

## Example

User asks: *"What were the top 5 merchant categories by total transaction amount?"*

```sql
SELECT merchant_category, ROUND(SUM(amount), 2) AS total_amount
FROM transactions
GROUP BY merchant_category
ORDER BY total_amount DESC
LIMIT 5;
```

Then explain the result in one or two sentences.
