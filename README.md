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
3. **Đọc ví dụ mẫu** — `.claude/skills/sql-helper/SKILL.md`, và xem qua `SCHEMA.md` để biết dữ liệu gồm những gì.
4. **Đặt câu hỏi bằng ngôn ngữ tự nhiên** — cùng nhau làm qua `exercises.md`.
5. **Tự xây dựng skill của riêng bạn** — sao chép `templates/skill-template/SKILL.md`, viết quy tắc riêng của bạn, rồi thử nghiệm.
6. **Chia sẻ kết quả** — một vài tình nguyện viên demo skill của mình trực tiếp.

## Repo này có gì

- `dataset/` — file CSV gốc từ Kaggle (bị git bỏ qua; không được đóng gói vào Codespace).
- `data/workshop.duckdb` — cơ sở dữ liệu đã được chuẩn bị và nạp sẵn dữ liệu mà người tham gia thực sự truy vấn (được theo dõi qua Git LFS).
- `SCHEMA.md` — từ điển dữ liệu: mọi bảng, cột, kiểu dữ liệu, và giá trị ví dụ.
- `exercises.md` — luồng bài tập của workshop và các câu hỏi ví dụ.
- `.claude/skills/sql-helper/`, `.codex/skills/sql-helper/` — skill ví dụ mẫu.
- `templates/skill-template/` — khung mẫu trống cho bài tập "tự xây dựng skill".
- `.devcontainer/` — môi trường Codespaces mở một lần là dùng được ngay (DuckDB CLI + Claude Code + Codex CLI + các extension VS Code, đã cài sẵn).
- `docs/setup/` — kế hoạch thiết lập của ban tổ chức và các hướng dẫn thiết lập từng bước cho local/Codespaces.
- `docs/reference/` — checklist hậu cần ngày diễn ra sự kiện và tài liệu xử lý sự cố dành riêng cho facilitator.
- `docs/architecture/` — tài liệu kiến trúc hệ thống kèm sơ đồ, dành cho kỹ sư muốn hiểu cách repo vận hành ở mức hệ thống.

## Cách hoạt động

Người tham gia mở một môi trường phát triển đã được dựng sẵn (DuckDB + dữ liệu + Claude Code + Codex CLI), đọc một từ điển dữ liệu ngắn gọn mô tả bộ dữ liệu, rồi đặt câu hỏi bằng ngôn ngữ tự nhiên — các câu hỏi này sẽ được chuyển thành SQL và thực thi trên dữ liệu — không cần tự tìm hiểu dữ liệu thủ công.

Xem `docs/setup/WORKSHOP_SETUP_PLAN.md` để có hướng dẫn thiết lập và tổ chức đầy đủ.
