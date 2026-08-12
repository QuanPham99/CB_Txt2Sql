# Hướng Dẫn Thiết Lập Workshop — Chạy Cục Bộ (không cần GitHub/Codespaces)

**Đúng vậy — repo này chạy tốt ở máy cục bộ.** Không có gì trong workshop thực sự phụ thuộc vào Codespaces; `.devcontainer/postCreate.sh` chỉ làm ba việc mà bất kỳ máy Mac/Linux nào (hoặc WSL trên Windows) đều có thể làm trực tiếp: cài DuckDB CLI, cài Claude Code và Codex CLI, và xác nhận `data/workshop.duckdb` đã nạp thành công. Hướng dẫn này thực hiện các bước tương tự trực tiếp trên máy của bạn, không cần container.

Có hai cách để chạy cục bộ — chọn một:

| Cách tiếp cận | Khi nào nên dùng |
|---|---|
| **A. Chạy trực tiếp trên máy của bạn** (hướng dẫn này) | Cách nhanh nhất để tự thử workshop, hoặc dùng chung một máy cho một nhóm nhỏ trực tiếp. Không cần Docker. |
| **B. Qua devcontainer, trong Docker** (`Iteration_0_LocalTesting.md`) | Bạn đang kiểm thử *đúng* môi trường mà người tham gia sẽ nhận trong Codespaces — cùng base image, cùng `postCreate.sh`/`postAttach.sh`, tách biệt khỏi máy của bạn. Dùng cách này trước một workshop thật để phát hiện lỗi riêng của container. |

Hướng dẫn này bao phủ cách **A**. Nếu bạn muốn môi trường giống hệt container, dừng ở đây và chuyển sang `Iteration_0_LocalTesting.md`.

> Repo: `QuanPham99/CB_Txt2Sql` (remote `origin`, nhánh `main`).

---

## 0. Điều kiện tiên quyết

- **Git** kèm **Git LFS** đã cài đặt (`git lfs version` phải chạy thành công — `data/workshop.duckdb` được lưu qua LFS; nếu không có LFS bạn sẽ chỉ nhận một file pointer nhỏ thay vì dữ liệu thật).
- **Node.js + npm** (`node --version`) — cần thiết để `npm install -g @anthropic-ai/claude-code`.
- **curl**.
- macOS hoặc Linux, hoặc **WSL2** trên Windows — các lệnh cài đặt trong `postCreate.sh` dựa trên Bash/curl và giả định một shell kiểu Unix. Windows thuần (cmd/PowerShell) không được hỗ trợ ở đây.
- Một **tài khoản Claude.ai** với gói đang hoạt động (Pro/Max), hoặc một Anthropic API key cá nhân.
- Một **tài khoản ChatGPT** với quyền truy cập Codex (Plus/Pro/Business/Edu), hoặc một OpenAI API key cá nhân.

---

## 1. Clone repo

```bash
git clone git@github.com:QuanPham99/CB_Txt2Sql.git
cd CB_Txt2Sql
```

Nếu bạn chưa cài Git LFS, hãy cài *trước* khi clone (hoặc chạy `git lfs pull` ngay sau đó):

```bash
git lfs install
git lfs pull
```

---

## 2. Xác nhận dữ liệu đã pull đúng

```bash
ls -la data/workshop.duckdb
```

Kỳ vọng một file thật, ~75MB. Nếu chỉ vài trăm byte, đó là một pointer LFS chưa được resolve — chạy lại `git lfs pull` rồi kiểm tra lại.

```bash
duckdb data/workshop.duckdb -c "SELECT count(*) FROM transactions;"
```

Nếu bạn chưa có DuckDB CLI, cài ngay bây giờ (đây là cùng lệnh mà `postCreate.sh` chạy):

```bash
curl -fsSL https://install.duckdb.org | sh
export PATH="$HOME/.duckdb/cli/latest:$PATH"
echo 'export PATH="$HOME/.duckdb/cli/latest:$PATH"' >> ~/.bashrc   # hoặc ~/.zshrc
```

Kỳ vọng `2000000`.

---

## 3. Cài các CLI

```bash
npm install -g @anthropic-ai/claude-code
```

```bash
curl -fsSL https://chatgpt.com/codex/install.sh | sh
export PATH="$HOME/.local/bin:$PATH"
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc   # hoặc ~/.zshrc
```

Kiểm tra:

```bash
claude --version
codex --version
```

---

## 4. Xác thực cả hai CLI

Từ thư mục gốc của repo:

```bash
claude
```
Làm theo URL đăng nhập được in ra, đăng nhập bằng tài khoản Claude.ai (hoặc dán một Anthropic API key cá nhân).

```bash
codex
```
Làm theo URL được in ra / prompt "Sign in with ChatGPT" (hoặc dán một OpenAI API key cá nhân).

OAuth cục bộ trên máy của chính bạn thường là con đường đăng nhập *mượt nhất* — không có các trục trặc redirect qua forwarded-port như Codespaces. Nếu một trong hai bị lặp vòng đăng nhập, xem hướng dẫn OAuth chung trong `../reference/FACILITATOR_TROUBLESHOOTING.md` (SSO tổ chức chặn redirect là nguyên nhân phổ biến nhất, không phụ thuộc vào việc dùng Codespaces hay cục bộ).

---

## 5. Xem lướt từ điển dữ liệu

```bash
open SCHEMA.md   # hoặc cứ mở nó trong editor của bạn
```

Đây là bước "hiểu dữ liệu" duy nhất cần thiết trước khi đặt câu hỏi — xác nhận nó vẫn còn mô tả chính xác `data/workshop.duckdb`.

---

## 6. Kiểm thử skill ví dụ mẫu

Cả `claude` và `codex` đều đọc skill dựa trên thư mục làm việc hiện tại, vì vậy hãy đảm bảo terminal của bạn đang ở trong thư mục gốc của repo trước khi khởi động chúng. Sau đó hỏi:

> 5 danh mục giao dịch có tổng số tiền cao nhất trong quý vừa rồi là gì?

Xác nhận nó:
- [ ] Dựa vào `SCHEMA.md` (không tự bịa tên cột)
- [ ] Hiển thị SQL đã chạy
- [ ] Áp dụng các quy tắc chung từ `.claude/skills/sql-helper/SKILL.md` (ví dụ `LIMIT 100` với dữ liệu thô, tiền tệ được làm tròn)
- [ ] Thực sự truy vấn `data/workshop.duckdb` và trả về số liệu thật

---

## 7. Làm qua các bài tập

```bash
open exercises.md
```

Tự làm qua tất cả các câu hỏi ví dụ, theo thứ tự. Nếu câu trả lời nào có vẻ sai hoặc model tự bịa cột/bảng, hãy sửa `SKILL.md` hoặc `SCHEMA.md` ngay bây giờ.

---

## 8. Xây dựng một skill tùy chỉnh dùng thử

1. Sao chép `templates/skill-template/SKILL.md` vào một folder mới, ví dụ `.claude/skills/scratch-test/`.
2. Điền vào 2–3 quy tắc chung.
3. Đặt lại câu hỏi và xác nhận hành vi đã thay đổi rõ rệt.
4. Xóa folder thử nghiệm khi xong (đừng commit nó).

---

## Chạy với một nhóm nhỏ, cục bộ, không dùng Codespaces

Nếu bạn đang kiểm thử với vài người trực tiếp thay vì một mình:

- Mỗi người cần clone riêng (Bước 1) và đăng nhập `claude`/`codex` riêng (Bước 4) — đăng nhập là theo từng tài khoản, không dùng chung.
- Không có gì tương đương với Codespaces prebuilds ở đây; Bước 2–3 của mỗi người sẽ mất thời gian tùy vào mạng/tốc độ cài npm của họ. Với một phòng lớn hơn vài người, Codespaces (`WORKSHOP_SETUP_GUIDE_CODESPACES.md`) là lựa chọn phù hợp hơn — đó cũng là những gì phần thiết lập "trước khi tham gia" trong README và `WORKSHOP_SETUP_PLAN.md` được xây dựng xoay quanh.

---

## Các lưu ý chỉ áp dụng khi chạy cục bộ

- `dataset/*.csv` (các file CSV gốc từ Kaggle) bị git bỏ qua — chúng không cần thiết lúc chạy, chỉ `data/workshop.duckdb` mới quan trọng. Nếu bạn cần dựng lại file `.duckdb` từ đầu, xem Phần 0 của `WORKSHOP_SETUP_PLAN.md`.
- Windows thuần (không có WSL) không được hướng dẫn này hỗ trợ — các lệnh cài đặt trong `postCreate.sh` chỉ chạy trên Bash. Người tham gia dùng Windows nên dùng WSL2 cục bộ, hoặc dùng Codespaces thay thế để tránh hẳn vấn đề hệ điều hành.
- Cách này không kiểm thử được các lỗi riêng của Codespaces (OAuth qua forwarded-port, pull LFS qua hạ tầng GitHub, khởi động prebuild, giới hạn chi tiêu). Nếu bạn là người tổ chức đang chuẩn bị cho một workshop thật trên Codespaces, vẫn nên chạy qua `WORKSHOP_SETUP_GUIDE_CODESPACES.md` trước sự kiện — một lần chạy cục bộ suôn sẻ không đảm bảo Codespaces cũng sẽ suôn sẻ.

---

## Tham khảo nhanh — cái gì nằm ở đâu

| File | Mục đích |
|---|---|
| `README.md` | Điểm vào dành cho người tham gia, badge Codespaces một-cú-click |
| `SCHEMA.md` | Từ điển dữ liệu mà AI dựa vào |
| `exercises.md` | Luồng bài tập trong workshop + câu hỏi ví dụ |
| `.claude/skills/sql-helper/`, `.codex/skills/sql-helper/` | Skill ví dụ mẫu (đồng bộ) |
| `templates/skill-template/` | Khung mẫu trống cho "tự xây dựng skill" |
| `data/workshop.duckdb` | DB đã nạp sẵn dữ liệu (Git LFS) — dữ liệu duy nhất người tham gia chạm vào |
| `docs/setup/WORKSHOP_SETUP_GUIDE_CODESPACES.md` | Cùng luồng, chạy trên một GitHub Codespace thật |
| `docs/setup/Iteration_0_LocalTesting.md` | Kiểm thử cục bộ tương đương container qua Docker + devcontainer CLI |
| `docs/setup/WORKSHOP_SETUP_PLAN.md` | Toàn bộ bối cảnh/lý do của ban tổ chức cho tất cả những điều trên |
| `docs/reference/DAY_OF_CHECKLIST.md` | Checklist trước workshop và hậu cần ngày diễn ra |
| `docs/reference/FACILITATOR_TROUBLESHOOTING.md` | Xử lý sự cố trực tiếp trong buổi (chỉ dành cho facilitator) |
