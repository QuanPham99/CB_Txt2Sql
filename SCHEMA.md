# Schema — Bộ Dữ Liệu Giao Dịch Ngân Hàng

File cơ sở dữ liệu: `data/workshop.duckdb` — 10 bảng, tổng cộng ~5.87 triệu dòng, khoảng thời gian **1995 – 2026**.
Nguồn: Kaggle "Banking Transactions Dataset" (dữ liệu tổng hợp — tên/email/số điện thoại là giả, không phải PII thật).

Mở bằng: `duckdb data/workshop.duckdb`

---

## `customers` (60,000 dòng)
Mỗi dòng là một khách hàng ngân hàng.
| cột | kiểu | ý nghĩa | ví dụ |
|---|---|---|---|
| customer_id | BIGINT | khóa chính | 1 |
| name | VARCHAR | họ tên đầy đủ (tổng hợp) | Pooja Garcia |
| gender | VARCHAR | Male / Female / Other | Female |
| date_of_birth | DATE | ngày sinh | 1987-12-11 |
| city, state | VARCHAR | nơi ở | Ahmedabad, Gujarat |
| phone, email | VARCHAR/BIGINT | thông tin liên hệ tổng hợp | customer0@mailbank.com |
| occupation | VARCHAR | Business Owner, Salaried - Private, Self Employed, Retired, Freelancer, Salaried - Government, Student | Retired |
| annual_income | BIGINT | thu nhập hàng năm, đơn vị tiền tệ nội địa | 200025 |
| join_date | DATE | ngày trở thành khách hàng | 2018-02-23 |
| credit_score | BIGINT | thang điểm 300–900 | 690 |

## `branches` (150 dòng)
| cột | kiểu | ý nghĩa | ví dụ |
|---|---|---|---|
| branch_id | BIGINT | khóa chính | 1 |
| branch_name, city, state | VARCHAR | vị trí | Pune Branch 1, Pune, Maharashtra |
| opened_date | DATE | ngày chi nhánh mở cửa | 2016-05-23 |
| ifsc_code | VARCHAR | mã định tuyến ngân hàng | BNK0000000 |

## `accounts` (95,000 dòng)
Mỗi dòng là một tài khoản ngân hàng. `customer_id` → `customers`, `branch_id` → `branches`.
| cột | kiểu | ý nghĩa | ví dụ |
|---|---|---|---|
| account_id | BIGINT | khóa chính | 1 |
| account_type | VARCHAR | Salary, Current, NRI, Savings, Fixed Deposit | Current |
| balance | DOUBLE | số dư hiện tại | 95902.0 |
| open_date | DATE | ngày mở tài khoản | 2019-10-20 |
| status | VARCHAR | Active, Dormant, Closed | Active |

## `transactions` (2,000,000 dòng)
Giao dịch ở cấp độ tài khoản ngân hàng. `account_id` → `accounts`.
| cột | kiểu | ý nghĩa | ví dụ |
|---|---|---|---|
| transaction_id | BIGINT | khóa chính | 1 |
| txn_date | DATE | ngày giao dịch | 2018-03-13 |
| txn_type | VARCHAR | Deposit, Withdrawal, Transfer Out, Transfer In, Fee Debit, Interest Credit | Deposit |
| amount | DOUBLE | số tiền giao dịch (luôn dương; chiều giao dịch được suy ra từ txn_type) | 1817.91 |
| channel | VARCHAR | POS, Mobile App, Branch, UPI, Online Banking, ATM | Online Banking |
| merchant_category | VARCHAR | Salary Credit, Fund Transfer, ATM Withdrawal, Shopping, Dining, Groceries, Utilities, Entertainment, Travel, Fuel, Rent, Insurance, Education, Healthcare | Salary Credit |

## `cards` (65,000 dòng)
`customer_id` → `customers`, `account_id` → `accounts`.
| cột | kiểu | ý nghĩa | ví dụ |
|---|---|---|---|
| card_id | BIGINT | khóa chính | 1 |
| card_type | VARCHAR | Debit, Credit - Classic, Credit - Gold, Credit - Platinum | Credit - Gold |
| issue_date, expiry_date | DATE | thời hạn hiệu lực | 2018-12-05 / 2023-12-04 |
| credit_limit | BIGINT | 0 với thẻ ghi nợ (debit) | 0 |
| status | VARCHAR | Active, Blocked, Expired | Active |

## `card_transactions` (3,000,000 dòng — bảng lớn nhất)
Giao dịch mua sắm/rút tiền ở cấp độ thẻ. `card_id` → `cards`.
| cột | kiểu | ý nghĩa | ví dụ |
|---|---|---|---|
| card_txn_id | BIGINT | khóa chính | 1 |
| txn_date | DATE | ngày giao dịch | 2025-01-28 |
| merchant_category | VARCHAR | cùng danh sách category với `transactions.merchant_category` | Education |
| amount | DOUBLE | số tiền giao dịch | 2162.41 |
| is_fraud | BIGINT | cờ 0/1 | 0 |

## `loans` (22,000 dòng)
`customer_id` → `customers`, `branch_id` → `branches`.
| cột | kiểu | ý nghĩa | ví dụ |
|---|---|---|---|
| loan_id | BIGINT | khóa chính | 1 |
| loan_type | VARCHAR | Auto, Business, Education, Gold, Home, Personal Loan | Auto Loan |
| loan_amount | DOUBLE | số tiền gốc | 310670.27 |
| interest_rate | DOUBLE | % hàng năm, ví dụ 9.54 = 9.54% | 9.54 |
| term_months | BIGINT | thời hạn vay | 60 |
| start_date | DATE | ngày giải ngân | 2020-06-16 |
| status | VARCHAR | Active, Closed, Defaulted, Written Off | Active |

## `loan_payments` (600,000 dòng)
`loan_id` → `loans`.
| cột | kiểu | ý nghĩa | ví dụ |
|---|---|---|---|
| payment_id | BIGINT | khóa chính | 1 |
| payment_date | DATE | ngày thanh toán | 2020-05-06 |
| amount_paid | DOUBLE | tổng số tiền thanh toán | 8144.05 |
| principal_component, interest_component | DOUBLE | phần chia của `amount_paid` | 5930.89 / 2213.16 |
| late_payment_flag | BIGINT | cờ 0/1 | 0 |

## `employees` (1,800 dòng)
`branch_id` → `branches`.
| cột | kiểu | ý nghĩa | ví dụ |
|---|---|---|---|
| employee_id | BIGINT | khóa chính | 1 |
| role | VARCHAR | Teller, Customer Service, Relationship Manager, Loan Officer, Branch Manager, Compliance Officer | Customer Service |
| hire_date | DATE | | 2016-11-09 |
| salary | BIGINT | lương hàng năm | 62479 |

## `support_tickets` (25,000 dòng)
`customer_id` → `customers`.
| cột | kiểu | ý nghĩa | ví dụ |
|---|---|---|---|
| ticket_id | BIGINT | khóa chính | 1 |
| issue_type | VARCHAR | Loan Query, Interest Query, KYC Update, Wrong Debit, Card Blocked, Cheque Bounce, Account Statement, App Login Issue, Net Banking Issue, Fraud Report | App Login Issue |
| date_opened, date_resolved | DATE | vòng đời ticket | 2024-08-04 / 2024-08-19 |
| status | VARCHAR | Open, Resolved, Escalated | Resolved |
| satisfaction_score | BIGINT | 1–5, chỉ có ý nghĩa khi đã resolved | 5 |

---

## Lưu ý & điểm đặc biệt
- Không có giá trị NULL ở bất kỳ cột nào trong cả 10 bảng — dữ liệu đã được làm sạch trước.
- Mọi cột khóa chính/khóa ngoại đều là BIGINT; join bằng khớp ID chính xác (không cần join theo chuỗi).
- `transactions` và `card_transactions` là hai nhật ký giao dịch riêng biệt (cấp tài khoản vs. cấp thẻ) — đừng `UNION` chúng nếu không tính đến sự khác biệt về mức độ chi tiết (grain) và cột dữ liệu.
- Các cột `amount` không có dấu (unsigned); chiều giao dịch được xác định từ `txn_type` (ví dụ `Withdrawal` so với `Deposit`).
- Dữ liệu có ngày tháng đến 2026-07-12 (bao gồm cả ngày tổng hợp trong tương lai) — đừng mặc định "hôm nay" khi câu hỏi nói "gần đây" hoặc "tháng trước"; hãy hỏi người tham gia họ muốn lấy mốc ngày nào, hoặc dùng `MAX(txn_date)` của bảng liên quan làm "hiện tại".
