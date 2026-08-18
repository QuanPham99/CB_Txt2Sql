# Schema — Bộ Dữ Liệu Tech Salary (mở rộng, tùy chọn)

File cơ sở dữ liệu: `data/tech_salary.duckdb` — 2 bảng, tổng cộng ~15.000 dòng, các tin đăng tuyển từ **2026-08-01 đến 2026-08-05**.
Nguồn: Kaggle "Global Tech Salary Dataset" (dữ liệu tổng hợp — tên công ty và mô tả công việc là giả, không phải dữ liệu thật).

Mở bằng: `duckdb data/tech_salary.duckdb`

Đây là bộ dữ liệu **độc lập hoàn toàn** với `data/workshop.duckdb` — không có cột nào dùng để join giữa hai database này (không có `customer_id` chung, không có id trùng khớp có ý nghĩa). Dùng cho Bài tập 2 ở `WORKSHOP_EXERCISES.md` (Bước 7).

---

## `global_tech_market_2026` (12.003 dòng)
Mỗi dòng là một tin đăng tuyển vị trí tech, tổng hợp từ nhiều nguồn khác nhau (HackerNews, Glassdoor, trang tuyển dụng của công ty, LinkedIn).
| cột | kiểu | ý nghĩa | ví dụ |
|---|---|---|---|
| job_id | VARCHAR | khóa chính (dạng chuỗi, ví dụ `OGWIP_100001`) | OGWIP_100001 |
| job_title | VARCHAR | chức danh, 20 giá trị cố định (Data Scientist, Software Engineer, DevOps Engineer, ...) | Product Manager |
| company_name | VARCHAR | tên công ty (giả định), 17 giá trị cố định | European Space Agency |
| location | VARCHAR | thành phố/quốc gia hoặc "Remote - ..." | Austin, TX, USA |
| salary_min_usd, salary_max_usd | BIGINT | khoảng lương chào mời, đơn vị USD (luôn min ≤ max) | 81405 / 113143 |
| tech_stack | VARCHAR | chuỗi công nghệ liên quan, phân tách bằng dấu phẩy, 10 tổ hợp cố định | Python, SQL, TensorFlow, PyTorch |
| source | VARCHAR | nguồn tin đăng: HackerNews, Glassdoor_Scrape, Company_Career_Page, LinkedIn_Proxy | HackerNews |
| description | VARCHAR | mô tả công việc dạng câu văn, sinh tự động từ các cột khác (không có thông tin mới) | "We are European Space Agency, looking for a Product Manager based in Austin, TX, USA. ..." |
| date_posted | TIMESTAMP | thời điểm đăng tin | 2026-08-04 05:00:00 |

## `usajobs_tech_roles_2026` (2.997 dòng)
Cùng cấu trúc cột hệ với `global_tech_market_2026`, nhưng chỉ chứa tin đăng có `source = 'USAJOBS'` (vai trò tech tại các cơ quan chính phủ Mỹ, ví dụ NASA, FBI, Department of Defense). Xem bảng cột ở trên — hai bảng dùng chung schema.
| cột | kiểu | ý nghĩa | ví dụ |
|---|---|---|---|
| job_id | VARCHAR | khóa chính | OGWIP_100000 |
| job_title, company_name, location, salary_min_usd, salary_max_usd, tech_stack, source, description, date_posted | — | giống hệt `global_tech_market_2026` | — |

---

## Lưu ý & điểm đặc biệt
- Không có giá trị NULL ở bất kỳ cột nào trong cả hai bảng.
- **`job_id` không trùng nhau giữa hai bảng** (0 dòng khớp khi join) — đây là hai tập tin đăng tuyển tách biệt (một tập tổng hợp toàn cầu, một tập lọc riêng nguồn USAJOBS), không phải bảng cha/con. Vẫn có thể `UNION ALL` hai bảng nếu câu hỏi cần nhìn toàn bộ tin đăng, vì schema giống hệt nhau.
- `job_id` là **VARCHAR**, không phải số — khác với `schemas/BANK_DATASET_SCHEMA.md`, nơi mọi khóa chính đều là BIGINT. Đừng ép kiểu số khi so sánh/join cột này.
- `tech_stack` là một chuỗi văn bản chứa nhiều công nghệ phân tách bằng dấu phẩy (ví dụ `"Python, SQL, TensorFlow, PyTorch"`), không phải danh sách (array) hay bảng con — muốn lọc theo một công nghệ cụ thể cần dùng `LIKE '%...%'` hoặc `list_contains(string_split(tech_stack, ', '), '...')`.
- `description` được sinh tự động từ các cột khác trong cùng dòng (company_name, job_title, location, tech_stack, salary_min_usd, salary_max_usd) — không chứa thông tin nào ngoài những gì đã có ở các cột cấu trúc, nên thường không cần query trên cột này.
- Dữ liệu chỉ trải dài 5 ngày (2026-08-01 → 2026-08-05) — khác hẳn `workshop.duckdb` (nhiều năm dữ liệu); các câu hỏi theo kiểu "xu hướng theo thời gian" sẽ không có nhiều ý nghĩa trên bộ dữ liệu này.
- `location`, `job_title`, `company_name`, `tech_stack` đều là tập giá trị **cố định, số lượng nhỏ** (16, 20, 17, 10 giá trị tương ứng) — phù hợp để liệt kê toàn bộ giá trị hợp lệ bằng `SELECT DISTINCT` khi cần, thay vì đoán chính tả.
