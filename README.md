# CB_Txt2Sql — Workshop Kỹ Năng Text-to-SQL

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/QuanPham99/CB_Txt2Sql)

Một workshop thực hành, nơi người tham gia xây dựng một **Claude Skill / Codex Skill** để chuyển câu hỏi bằng ngôn ngữ tự nhiên thành SQL, chạy trực tiếp trên bộ dữ liệu giao dịch ngân hàng trong DuckDB.

## Trước khi tham gia

- Có tài khoản GitHub, đã đăng nhập.
- Có tài khoản **Claude.ai** với gói đang hoạt động (Pro/Max), hoặc một Anthropic API key cá nhân.
- Có tài khoản **ChatGPT** với quyền truy cập Codex (Plus/Pro/Business/Edu), hoặc một OpenAI API key cá nhân.
- Trình duyệt đã đăng nhập cả hai.

## Chương trình (nửa ngày)

1. **Mở Codespace của bạn** — nhấn vào badge phía trên, hoặc Code → Codespaces → Create codespace on main. Đợi container (đã được dựng sẵn) khởi động xong.
2. **Xác thực** — chạy `claude` và `codex` trong terminal và làm theo hướng dẫn đăng nhập.
3. **Đọc ví dụ mẫu** — `.claude/skills/sql-helper/SKILL.md`, và xem qua `schemas/BANK_DATASET_SCHEMA.md` để biết dữ liệu gồm những gì.
4. **Đặt câu hỏi bằng ngôn ngữ tự nhiên** — cùng nhau làm qua `WORKSHOP_EXERCISES.md`.
5. **Tự xây dựng skill của riêng bạn** — sao chép `templates/skill-template/SKILL.md`, viết quy tắc riêng của bạn, rồi thử nghiệm.
6. **Chia sẻ kết quả** — một vài tình nguyện viên demo skill của mình trực tiếp.

## Mở rộng (tùy chọn): bộ dữ liệu Tech Salary

Sau khi hoàn thành Bước 5, thử `WORKSHOP_EXERCISES.md` → "Bước 7 (tùy chọn)":
bài tập thứ hai của workshop — cùng 3 cấp độ Cơ bản/Trung cấp/Nâng cao như
Bước 3, nhưng trên một bộ dữ liệu hoàn toàn khác (`data/tech_salary.duckdb`) —
mở rộng skill bạn vừa xây để nó cũng hoạt động được với database này, chứng
minh pattern skill-building bạn học được không chỉ áp dụng riêng cho dữ liệu
ngân hàng.

## Làm việc với dữ liệu của riêng bạn (tùy chọn, chạy cục bộ)

Muốn thử pattern này với file CSV của chính bạn? Xem
`participants/LOCAL_SETUP_GUIDE.md` (Phần C) — đặt file vào `my-data/`,
chạy `./participants/local_setup/load_custom_data.sh`, rồi tự viết schema và skill của riêng bạn từ
`templates/custom-data-skill-template/SKILL.md`. Chỉ hỗ trợ file `.csv`; Excel
được giới thiệu riêng qua Claude for Excel, không phải một phần của repo này.
Đây là bài tập chạy trên máy cá nhân của bạn (không phải Codespaces), có trợ
lý kỹ thuật hỗ trợ trực tiếp nếu cần cài đặt từ đầu.

## Repo này có gì

- `dataset/` — file CSV gốc từ Kaggle cho dữ liệu ngân hàng (bị git bỏ qua; không được đóng gói vào Codespace).
- `data/workshop.duckdb` — cơ sở dữ liệu ngân hàng đã được chuẩn bị và nạp sẵn dữ liệu mà người tham gia thực sự truy vấn (được theo dõi qua Git LFS).
- `schemas/BANK_DATASET_SCHEMA.md` — từ điển dữ liệu ngân hàng: mọi bảng, cột, kiểu dữ liệu, và giá trị ví dụ.
- `data/tech_salary.duckdb`, `schemas/TECH_SALARY_DATASET_SCHEMA.md` — bộ dữ liệu thứ hai (Tech Salary) và từ điển dữ liệu tương ứng, dùng cho bài tập mở rộng tùy chọn.
- `WORKSHOP_EXERCISES.md` — luồng bài tập của workshop (2 bài tập: Bank Transaction Schema và Salary Schema) và các câu hỏi ví dụ.
- `.claude/skills/sql-helper/`, `.codex/skills/sql-helper/` — skill ví dụ mẫu.
- `templates/skill-template/` — khung mẫu trống cho bài tập "tự xây dựng skill".
- `my-data/`, `participants/local_setup/load_custom_data.sh`, `templates/custom-data-skill-template/` — luồng dữ liệu tùy chỉnh cục bộ (tùy chọn, chỉ CSV): đặt file CSV của bạn vào `my-data/`, chạy `load_custom_data.sh`, rồi xây skill từ khung mẫu này.
- `.devcontainer/` — môi trường Codespaces mở một lần là dùng được ngay (DuckDB CLI + Claude Code + Codex CLI + các extension VS Code, đã cài sẵn).
- `participants/local_setup/setup.sh` — thiết lập tương đương trên máy cục bộ (không dùng Codespaces); xem `participants/LOCAL_SETUP_GUIDE.md` để có hướng dẫn cài đặt từng bước, kể cả cho máy hoàn toàn mới.
- `participants/` — mọi tài nguyên dành cho người tham gia: tài liệu kiến trúc hệ thống (`ARCHITECTURE.md`), đáp án mẫu để tự kiểm tra bài tập (`exercises_answer_key_bank_schema.ipynb` cho dữ liệu ngân hàng, `exercises_answer_key_salary_schema.ipynb` cho dữ liệu Tech Salary), và hướng dẫn cục bộ/dữ liệu tùy chỉnh (`LOCAL_SETUP_GUIDE.md`) — xem `participants/README.md` để có danh sách đầy đủ.
- `organizers/` — dành cho ban tổ chức: kế hoạch thiết lập, các hướng dẫn dry-run cho local/Codespaces, checklist ngày diễn ra, tài liệu xử lý sự cố, và công cụ dựng bộ dữ liệu Tech Salary (`tech_salary_dataset/`, git-ignored, là input cho `organizers/build_tech_salary_db.sh`) — xem `organizers/README.md` nếu bạn là người tổ chức workshop này.

## Cách hoạt động

Người tham gia mở một môi trường phát triển đã được dựng sẵn (DuckDB + dữ liệu + Claude Code + Codex CLI), đọc một từ điển dữ liệu ngắn gọn mô tả bộ dữ liệu, rồi đặt câu hỏi bằng ngôn ngữ tự nhiên — các câu hỏi này sẽ được chuyển thành SQL và thực thi trên dữ liệu — không cần tự tìm hiểu dữ liệu thủ công.

Xem `organizers/WORKSHOP_SETUP_PLAN.md` để có hướng dẫn thiết lập và tổ chức đầy đủ.
