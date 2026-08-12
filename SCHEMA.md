# Schema — Banking Transactions Dataset

Database file: `data/workshop.duckdb` — 10 tables, ~5.87M rows total, dates span **1995 – 2026**.
Source: Kaggle "Banking Transactions Dataset" (synthetic data — names/emails/phones are fake, not real PII).

Open it with: `duckdb data/workshop.duckdb`

---

## `customers` (60,000 rows)
One row per bank customer.
| column | type | meaning | example |
|---|---|---|---|
| customer_id | BIGINT | primary key | 1 |
| name | VARCHAR | full name (synthetic) | Pooja Garcia |
| gender | VARCHAR | Male / Female / Other | Female |
| date_of_birth | DATE | birth date | 1987-12-11 |
| city, state | VARCHAR | home location | Ahmedabad, Gujarat |
| phone, email | VARCHAR/BIGINT | synthetic contact info | customer0@mailbank.com |
| occupation | VARCHAR | Business Owner, Salaried - Private, Self Employed, Retired, Freelancer, Salaried - Government, Student | Retired |
| annual_income | BIGINT | yearly income, local currency units | 200025 |
| join_date | DATE | when they became a customer | 2018-02-23 |
| credit_score | BIGINT | 300–900 scale | 690 |

## `branches` (150 rows)
| column | type | meaning | example |
|---|---|---|---|
| branch_id | BIGINT | primary key | 1 |
| branch_name, city, state | VARCHAR | location | Pune Branch 1, Pune, Maharashtra |
| opened_date | DATE | branch opening date | 2016-05-23 |
| ifsc_code | VARCHAR | bank routing code | BNK0000000 |

## `accounts` (95,000 rows)
One row per bank account. `customer_id` → `customers`, `branch_id` → `branches`.
| column | type | meaning | example |
|---|---|---|---|
| account_id | BIGINT | primary key | 1 |
| account_type | VARCHAR | Salary, Current, NRI, Savings, Fixed Deposit | Current |
| balance | DOUBLE | current balance | 95902.0 |
| open_date | DATE | account opening date | 2019-10-20 |
| status | VARCHAR | Active, Dormant, Closed | Active |

## `transactions` (2,000,000 rows)
Bank-account-level transactions. `account_id` → `accounts`.
| column | type | meaning | example |
|---|---|---|---|
| transaction_id | BIGINT | primary key | 1 |
| txn_date | DATE | transaction date | 2018-03-13 |
| txn_type | VARCHAR | Deposit, Withdrawal, Transfer Out, Transfer In, Fee Debit, Interest Credit | Deposit |
| amount | DOUBLE | transaction amount (always positive; sign is implied by txn_type) | 1817.91 |
| channel | VARCHAR | POS, Mobile App, Branch, UPI, Online Banking, ATM | Online Banking |
| merchant_category | VARCHAR | Salary Credit, Fund Transfer, ATM Withdrawal, Shopping, Dining, Groceries, Utilities, Entertainment, Travel, Fuel, Rent, Insurance, Education, Healthcare | Salary Credit |

## `cards` (65,000 rows)
`customer_id` → `customers`, `account_id` → `accounts`.
| column | type | meaning | example |
|---|---|---|---|
| card_id | BIGINT | primary key | 1 |
| card_type | VARCHAR | Debit, Credit - Classic, Credit - Gold, Credit - Platinum | Credit - Gold |
| issue_date, expiry_date | DATE | validity window | 2018-12-05 / 2023-12-04 |
| credit_limit | BIGINT | 0 for debit cards | 0 |
| status | VARCHAR | Active, Blocked, Expired | Active |

## `card_transactions` (3,000,000 rows — largest table)
Card-level purchases/withdrawals. `card_id` → `cards`.
| column | type | meaning | example |
|---|---|---|---|
| card_txn_id | BIGINT | primary key | 1 |
| txn_date | DATE | transaction date | 2025-01-28 |
| merchant_category | VARCHAR | same category list as `transactions.merchant_category` | Education |
| amount | DOUBLE | transaction amount | 2162.41 |
| is_fraud | BIGINT | 0/1 flag | 0 |

## `loans` (22,000 rows)
`customer_id` → `customers`, `branch_id` → `branches`.
| column | type | meaning | example |
|---|---|---|---|
| loan_id | BIGINT | primary key | 1 |
| loan_type | VARCHAR | Auto, Business, Education, Gold, Home, Personal Loan | Auto Loan |
| loan_amount | DOUBLE | principal amount | 310670.27 |
| interest_rate | DOUBLE | annual %, e.g. 9.54 = 9.54% | 9.54 |
| term_months | BIGINT | loan duration | 60 |
| start_date | DATE | disbursement date | 2020-06-16 |
| status | VARCHAR | Active, Closed, Defaulted, Written Off | Active |

## `loan_payments` (600,000 rows)
`loan_id` → `loans`.
| column | type | meaning | example |
|---|---|---|---|
| payment_id | BIGINT | primary key | 1 |
| payment_date | DATE | date paid | 2020-05-06 |
| amount_paid | DOUBLE | total payment | 8144.05 |
| principal_component, interest_component | DOUBLE | split of `amount_paid` | 5930.89 / 2213.16 |
| late_payment_flag | BIGINT | 0/1 flag | 0 |

## `employees` (1,800 rows)
`branch_id` → `branches`.
| column | type | meaning | example |
|---|---|---|---|
| employee_id | BIGINT | primary key | 1 |
| role | VARCHAR | Teller, Customer Service, Relationship Manager, Loan Officer, Branch Manager, Compliance Officer | Customer Service |
| hire_date | DATE | | 2016-11-09 |
| salary | BIGINT | annual salary | 62479 |

## `support_tickets` (25,000 rows)
`customer_id` → `customers`.
| column | type | meaning | example |
|---|---|---|---|
| ticket_id | BIGINT | primary key | 1 |
| issue_type | VARCHAR | Loan Query, Interest Query, KYC Update, Wrong Debit, Card Blocked, Cheque Bounce, Account Statement, App Login Issue, Net Banking Issue, Fraud Report | App Login Issue |
| date_opened, date_resolved | DATE | ticket lifecycle | 2024-08-04 / 2024-08-19 |
| status | VARCHAR | Open, Resolved, Escalated | Resolved |
| satisfaction_score | BIGINT | 1–5, only meaningful once resolved | 5 |

---

## Quirks & notes
- No NULL values in any column across all 10 tables — the data is pre-cleaned.
- All primary/foreign key columns are BIGINT; join by exact ID match (no string joins needed).
- `transactions` and `card_transactions` are two separate transaction logs (account-level vs. card-level) — don't `UNION` them without accounting for the different grain and columns.
- `amount` columns are unsigned; direction comes from `txn_type` (e.g. `Withdrawal` vs `Deposit`).
- Dates range up to 2026-07-12 (synthetic future dates included) — don't assume "today" when a question says "recent" or "last month"; ask the participant what reference date they mean, or use `MAX(txn_date)` from the relevant table as "now".
