---
name: sql-helper
description: Truy vấn dữ liệu bằng ngôn ngữ tự nhiên trên bất kỳ database DuckDB nào của workshop này (giao dịch ngân hàng — accounts, transactions, cards, loans, customers, branches, employees, support tickets — hoặc dữ liệu lương/tuyển dụng ngành công nghệ — job posting, salary, tech stack). Skill tự xác định câu hỏi thuộc database nào trước khi viết SQL. Các cụm từ kích hoạt bao gồm "có bao nhiêu...", "tổng số... là bao nhiêu", "khách hàng/tài khoản/chi nhánh/vị trí/mức lương nào...", "text to SQL", "truy vấn dữ liệu".
---

# SQL Helper

Bạn trả lời các câu hỏi bằng ngôn ngữ tự nhiên bằng cách viết và chạy SQL trên một file DuckDB cục bộ. Repo này có thể có **nhiều database độc lập** — mỗi database có một file từ điển dữ liệu (data dictionary) tương ứng trong thư mục `schemas/`. Việc đầu tiên bạn làm, trước cả khi nghĩ tới SQL, là xác định câu hỏi đang nói về database nào.

## Bước 1 — Xác định đúng database

1. Liệt kê các file có trong `schemas/` (ví dụ `ls schemas/`) để biết hiện có những schema nào — đừng giả định chỉ có một.
2. Mỗi file schema mở đầu bằng một dòng "File cơ sở dữ liệu: `data/....duckdb`" nêu rõ chính xác nó mô tả database nào. Đọc dòng đó (và phần mô tả ngay sau) để hiểu chủ đề của từng database, thay vì đoán qua tên file.
3. So khớp chủ đề câu hỏi của người dùng với đúng một schema. Hiện tại repo có 2 schema đã biết (sẽ tự động có thêm nếu ai đó thêm file mới vào `schemas/`):

   | Schema | Database | Chủ đề |
   |---|---|---|
   | `schemas/BANK_DATASET_SCHEMA.md` | `data/workshop.duckdb` | Ngân hàng: khách hàng, tài khoản, giao dịch, thẻ, khoản vay, chi nhánh, nhân viên, ticket hỗ trợ |
   | `schemas/TECH_SALARY_DATASET_SCHEMA.md` | `data/tech_salary.duckdb` | Tin tuyển dụng ngành công nghệ: chức danh, công ty, mức lương, tech stack |

4. Nếu câu hỏi mơ hồ — có thể thuộc nhiều hơn một database, hoặc không khớp rõ với database nào đã biết — **hỏi lại người dùng để làm rõ** thay vì đoán hoặc trộn lẫn dữ liệu từ nhiều database.
5. Các database này **độc lập hoàn toàn với nhau** (không có khóa ngoại chung, không join được). Không bao giờ viết SQL nối/join dữ liệu giữa hai file `.duckdb` khác nhau. Nếu một câu hỏi thật sự cần cả hai (hiếm khi xảy ra), hãy chạy hai truy vấn riêng biệt trên hai file và tự tổng hợp kết quả bằng lời, không bằng SQL.

## Bước 2 — Nắm vững dữ liệu trước khi viết SQL

Đọc file schema tương ứng đã xác định ở Bước 1. Đây là nguồn thông tin duy nhất và chính xác cho tên bảng, tên cột, kiểu dữ liệu, và các giá trị hợp lệ của database đó. Không bao giờ tự bịa ra tên cột hoặc tên bảng không có trong đó — nếu câu hỏi cần dữ liệu không có trong schema, hãy nói rõ điều đó thay vì đoán mò.

## Bước 3 — Chạy truy vấn

Luôn truy vấn đúng file `.duckdb` tương ứng với schema đã chọn ở Bước 1, ví dụ:

```bash
duckdb data/workshop.duckdb -c "SELECT ... "
```

hoặc

```bash
duckdb data/tech_salary.duckdb -c "SELECT ... "
```

## Quy tắc chung

1. **Luôn hiển thị câu SQL đã chạy** trước khi hiển thị kết quả, để người dùng có thể học theo.
2. **Luôn dùng `LIMIT 100`** với bất kỳ truy vấn nào trả về dữ liệu thô theo dòng, trừ khi người dùng yêu cầu rõ nhiều hơn hoặc truy vấn đã là dạng tổng hợp chỉ trả về vài dòng.
3. **Không bao giờ tự bịa tên cột hoặc tên bảng** — nếu không chắc chắn, hãy kiểm tra lại file schema tương ứng trong `schemas/` thay vì đoán.
4. **Ưu tiên tổng hợp thay vì liệt kê thô** — nếu câu hỏi có thể trả lời bằng `COUNT`, `SUM`, hoặc `GROUP BY`, hãy làm vậy thay vì trả về hàng trăm dòng dữ liệu thô.
5. **Nêu rõ các giả định** — ví dụ nếu "tháng trước" không rõ ràng do khoảng thời gian của dữ liệu, hãy nói rõ bạn đã dùng mốc ngày nào (xem phần "Lưu ý & điểm đặc biệt" trong file schema tương ứng).
6. **Làm tròn tiền tệ về 2 chữ số thập phân** trong câu trả lời cuối cùng, ngay cả khi cột dữ liệu gốc có độ chính xác cao hơn.
7. **Luôn nêu rõ bạn đang dùng database nào** (ví dụ "dựa trên `data/workshop.duckdb`") trong câu trả lời, để người dùng xác nhận được skill đã chọn đúng.

## Ví dụ

Người dùng hỏi: *"5 danh mục merchant có tổng số tiền giao dịch cao nhất là gì?"*

→ Đây là chủ đề ngân hàng ("merchant", "giao dịch") → chọn `schemas/BANK_DATASET_SCHEMA.md` / `data/workshop.duckdb`.

```sql
SELECT merchant_category, ROUND(SUM(amount), 2) AS total_amount
FROM transactions
GROUP BY merchant_category
ORDER BY total_amount DESC
LIMIT 5;
```

Người dùng hỏi: *"Mức lương trung bình cho vị trí Data Scientist là bao nhiêu?"*

→ Đây là chủ đề lương/tuyển dụng tech ("mức lương", "vị trí") → chọn `schemas/TECH_SALARY_DATASET_SCHEMA.md` / `data/tech_salary.duckdb`.

```sql
SELECT ROUND(AVG((salary_min_usd + salary_max_usd) / 2.0), 2) AS avg_salary
FROM (
    SELECT salary_min_usd, salary_max_usd, job_title FROM global_tech_market_2026
    UNION ALL
    SELECT salary_min_usd, salary_max_usd, job_title FROM usajobs_tech_roles_2026
)
WHERE job_title = 'Data Scientist';
```

Sau đó giải thích kết quả trong một hoặc hai câu, và nêu rõ database nào đã được dùng.
