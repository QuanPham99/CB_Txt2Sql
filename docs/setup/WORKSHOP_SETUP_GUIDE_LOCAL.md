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
- macOS hoặc Linux, hoặc **WSL2** trên Windows — các lệnh cài đặt trong `postCreate.sh` dựa trên Bash/curl và giả định một shell kiểu Unix. Windows thuần (cmd/PowerShell) không được hỗ trợ ở đây. Nếu máy chưa có gì cài sẵn (Git, Node, WSL2, ...), xem Phần 0b bên dưới — có hướng dẫn từng bước dành cho một trợ lý kỹ thuật làm cùng người tham gia không rành kỹ thuật.
- Một **tài khoản Claude.ai** với gói đang hoạt động (Pro/Max), hoặc một Anthropic API key cá nhân.
- Một **tài khoản ChatGPT** với quyền truy cập Codex (Plus/Pro/Business/Edu), hoặc một OpenAI API key cá nhân.

---

## 0b. Cài đặt từ máy hoàn toàn mới (dành cho trợ lý kỹ thuật hỗ trợ trực tiếp)

Phần này viết cho một **trợ lý kỹ thuật** đọc/làm cùng một người tham gia không
rành kỹ thuật, trên một máy chưa từng cài gì liên quan đến lập trình. Đưa
từng lệnh, giải thích ngắn gọn nó làm gì, rồi chạy. Nếu máy đã có sẵn
Git/Node/v.v., bỏ qua bước tương ứng và chuyển thẳng sang "1. Clone repo".

### Windows

1. Mở **PowerShell với quyền Administrator** (nhấn phím Windows, gõ
   "PowerShell", chuột phải vào kết quả → "Run as Administrator").
2. Cài WSL2 kèm Ubuntu — đây là một môi trường Linux chạy bên trong Windows;
   các lệnh cài đặt của workshop chỉ chạy trên Linux/macOS, không chạy trực
   tiếp trên Windows thuần:
   ```powershell
   wsl --install -d Ubuntu
   ```
3. **Máy gần như chắc chắn sẽ yêu cầu khởi động lại (restart)** sau lệnh
   trên — đây là bình thường, không phải lỗi hay máy bị treo. Khởi động lại
   máy khi được yêu cầu.
4. Sau khi khởi động lại, Ubuntu sẽ tự mở và hỏi bạn tạo một **username/
   password Linux** (khác với tài khoản đăng nhập Windows) — tạo một cái đơn
   giản, dễ nhớ, đây là tài khoản bạn sẽ dùng trong suốt workshop.
5. Từ giờ, mọi lệnh trong hướng dẫn này chạy **bên trong cửa sổ Ubuntu** đó
   (không phải PowerShell/cmd). Mở lại cửa sổ này bất cứ lúc nào bằng cách gõ
   `wsl` trong menu Start, hoặc mở app "Ubuntu".
6. Trong cửa sổ Ubuntu, cài các gói cần thiết:
   ```bash
   sudo apt update
   sudo apt install -y git git-lfs curl
   ```
7. Tiếp tục với "1. Clone repo" bên dưới — thực hiện trong cửa sổ Ubuntu này.

> Gợi ý hiệu năng: nếu clone repo vào trong hệ thống file của chính WSL2 (ví
> dụ `~/CB_Txt2Sql`) thay vì `/mnt/c/...`, mọi thứ sẽ chạy nhanh hơn đáng kể.
> Cả hai cách đều hoạt động được — nếu không chắc, dùng `~/CB_Txt2Sql`.

### macOS

1. Mở app **Terminal** (Spotlight: nhấn `Cmd + Space`, gõ "Terminal", Enter).
2. Kiểm tra xem máy đã có **Homebrew** chưa:
   ```bash
   brew --version
   ```
   Nếu báo lỗi "command not found", cài Homebrew:
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
   Làm theo hướng dẫn hiện trên màn hình (có thể yêu cầu nhập mật khẩu máy Mac).
3. Cài Git, Git LFS, Node.js:
   ```bash
   brew install git git-lfs node
   ```
4. Tiếp tục với "1. Clone repo" bên dưới, trong cùng cửa sổ Terminal này.

Sau khi hoàn tất Windows hoặc macOS ở trên, làm theo đúng các bước 1–8 phía
dưới (Clone repo → ... → Xây dựng skill tùy chỉnh) — không có gì khác biệt
từ đây trở đi, dù đang ở Ubuntu-trong-WSL2 hay macOS. Nếu có trục trặc trong
lúc cài đặt, xem mục "Hỗ trợ cài đặt cục bộ" trong
`../reference/FACILITATOR_TROUBLESHOOTING.md`.

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
open BANK_DATASET_SCHEMA.md   # hoặc cứ mở nó trong editor của bạn
```

Đây là bước "hiểu dữ liệu" duy nhất cần thiết trước khi đặt câu hỏi — xác nhận nó vẫn còn mô tả chính xác `data/workshop.duckdb`.

---

## 6. Kiểm thử skill ví dụ mẫu

Cả `claude` và `codex` đều đọc skill dựa trên thư mục làm việc hiện tại, vì vậy hãy đảm bảo terminal của bạn đang ở trong thư mục gốc của repo trước khi khởi động chúng. Sau đó hỏi:

> 5 danh mục giao dịch có tổng số tiền cao nhất trong quý vừa rồi là gì?

Xác nhận nó:
- [ ] Dựa vào `BANK_DATASET_SCHEMA.md` (không tự bịa tên cột)
- [ ] Hiển thị SQL đã chạy
- [ ] Áp dụng các quy tắc chung từ `.claude/skills/sql-helper/SKILL.md` (ví dụ `LIMIT 100` với dữ liệu thô, tiền tệ được làm tròn)
- [ ] Thực sự truy vấn `data/workshop.duckdb` và trả về số liệu thật

---

## 7. Làm qua các bài tập

```bash
open exercises.md
```

Tự làm qua tất cả các câu hỏi ví dụ, theo thứ tự. Nếu câu trả lời nào có vẻ sai hoặc model tự bịa cột/bảng, hãy sửa `SKILL.md` hoặc `BANK_DATASET_SCHEMA.md` ngay bây giờ.

---

## 8. Xây dựng một skill tùy chỉnh dùng thử

1. Sao chép `templates/skill-template/SKILL.md` vào một folder mới, ví dụ `.claude/skills/scratch-test/`.
2. Điền vào 2–3 quy tắc chung.
3. Đặt lại câu hỏi và xác nhận hành vi đã thay đổi rõ rệt.
4. Xóa folder thử nghiệm khi xong (đừng commit nó).

---

## 9. (Tùy chọn) Dữ liệu tùy chỉnh cục bộ — dùng file CSV của riêng bạn

Phần này chỉ áp dụng khi chạy cục bộ (không nằm trong luồng Codespaces
chính). Cần đã hoàn thành Bước 1–4 ở trên (repo đã clone, `claude`/`codex`
đã xác thực).

**Chỉ hỗ trợ file `.csv`.** Nếu dữ liệu của bạn đang ở dạng Excel, xuất từng
sheet cần dùng ra một file `.csv` riêng trước — Excel được hỗ trợ riêng qua
Claude for Excel, không phải một phần của repo/workshop này.

1. Tạo thư mục và đặt file CSV vào đó:
   ```bash
   mkdir -p my-data
   cp ~/Downloads/du_lieu_cua_ban.csv my-data/
   ```
2. Chạy:
   ```bash
   ./load_custom_data.sh
   ```
   Script nạp mỗi file CSV thành một bảng trong `data/custom.duckdb` (luôn
   xây lại từ đầu mỗi lần chạy) và in tóm tắt số dòng mỗi bảng.
3. Khám phá schema của chính bạn:
   ```bash
   duckdb data/custom.duckdb -c ".tables"
   duckdb data/custom.duckdb -c "DESCRIBE <tên_bảng>;"
   ```
4. Sao chép khung skill: `templates/custom-data-skill-template/SKILL.md` →
   `.claude/skills/<tên-của-bạn>/SKILL.md` (và mirror sang
   `.codex/skills/<tên-của-bạn>/`), rồi điền phần "Bảng & cột" bằng những gì
   bạn vừa khám phá ở bước 3.
5. Đặt câu hỏi bằng ngôn ngữ tự nhiên về dữ liệu của chính bạn.

Mỗi khi bạn thêm/sửa/xóa file trong `my-data/`, chạy lại `./load_custom_data.sh`
để đồng bộ `data/custom.duckdb`.

---

## Chạy với một nhóm nhỏ, cục bộ, không dùng Codespaces

Nếu bạn đang kiểm thử với vài người trực tiếp thay vì một mình:

- Mỗi người cần clone riêng (Bước 1) và đăng nhập `claude`/`codex` riêng (Bước 4) — đăng nhập là theo từng tài khoản, không dùng chung.
- Không có gì tương đương với Codespaces prebuilds ở đây; Bước 2–3 của mỗi người sẽ mất thời gian tùy vào mạng/tốc độ cài npm của họ. Với một phòng lớn hơn vài người, Codespaces (`WORKSHOP_SETUP_GUIDE_CODESPACES.md`) là lựa chọn phù hợp hơn — đó cũng là những gì phần thiết lập "trước khi tham gia" trong README và `WORKSHOP_SETUP_PLAN.md` được xây dựng xoay quanh.

---

## Các lưu ý chỉ áp dụng khi chạy cục bộ

- `dataset/*.csv` (các file CSV gốc từ Kaggle) bị git bỏ qua — chúng không cần thiết lúc chạy, chỉ `data/workshop.duckdb` mới quan trọng. Nếu bạn cần dựng lại file `.duckdb` từ đầu, xem Phần 0 của `WORKSHOP_SETUP_PLAN.md`.
- Windows thuần (không có WSL2) không được hướng dẫn này hỗ trợ trực tiếp — các lệnh cài đặt trong `postCreate.sh`/`setup.sh` chỉ chạy trên Bash. Xem Phần 0b để cài WSL2 từng bước; sau đó mọi thứ chạy y hệt macOS/Linux bên trong cửa sổ Ubuntu. Nếu không muốn cài WSL2, dùng Codespaces thay thế để tránh hẳn vấn đề hệ điều hành.
- Cách này không kiểm thử được các lỗi riêng của Codespaces (OAuth qua forwarded-port, pull LFS qua hạ tầng GitHub, khởi động prebuild, giới hạn chi tiêu). Nếu bạn là người tổ chức đang chuẩn bị cho một workshop thật trên Codespaces, vẫn nên chạy qua `WORKSHOP_SETUP_GUIDE_CODESPACES.md` trước sự kiện — một lần chạy cục bộ suôn sẻ không đảm bảo Codespaces cũng sẽ suôn sẻ.

---

## Tham khảo nhanh — cái gì nằm ở đâu

| File | Mục đích |
|---|---|
| `README.md` | Điểm vào dành cho người tham gia, badge Codespaces một-cú-click |
| `BANK_DATASET_SCHEMA.md` | Từ điển dữ liệu mà AI dựa vào |
| `exercises.md` | Luồng bài tập trong workshop + câu hỏi ví dụ |
| `.claude/skills/sql-helper/`, `.codex/skills/sql-helper/` | Skill ví dụ mẫu (đồng bộ) |
| `templates/skill-template/` | Khung mẫu trống cho "tự xây dựng skill" |
| `data/workshop.duckdb` | DB ngân hàng đã nạp sẵn dữ liệu (Git LFS) |
| `data/tech_salary.duckdb` | DB thứ hai (Tech Salary), dùng cho bài tập mở rộng tùy chọn — Bước 7 trong `exercises.md` |
| `TECH_SALARY_DATASET_SCHEMA.md` | Từ điển dữ liệu cho `data/tech_salary.duckdb` |
| `scripts/build_tech_salary_db.sh` | Công cụ nội bộ của ban tổ chức để dựng `data/tech_salary.duckdb` — không dành cho người tham gia |
| `load_custom_data.sh`, `my-data/` | Nạp file CSV của riêng bạn vào `data/custom.duckdb` (cục bộ, tùy chọn) — xem Phần 9 |
| `templates/custom-data-skill-template/` | Khung mẫu skill cho dữ liệu tùy chỉnh |
| `docs/setup/WORKSHOP_SETUP_GUIDE_CODESPACES.md` | Cùng luồng, chạy trên một GitHub Codespace thật |
| `docs/setup/Iteration_0_LocalTesting.md` | Kiểm thử cục bộ tương đương container qua Docker + devcontainer CLI |
| `docs/setup/WORKSHOP_SETUP_PLAN.md` | Toàn bộ bối cảnh/lý do của ban tổ chức cho tất cả những điều trên |
| `docs/reference/DAY_OF_CHECKLIST.md` | Checklist trước workshop và hậu cần ngày diễn ra |
| `docs/reference/FACILITATOR_TROUBLESHOOTING.md` | Xử lý sự cố trực tiếp trong buổi (chỉ dành cho facilitator) |
