# Hướng Dẫn Cục Bộ Dành Cho Người Tham Gia (Tùy chọn)

Tài liệu này dành cho hai trường hợp **tùy chọn**, chạy trên máy cá nhân của bạn thay vì Codespaces:

- **Phần A** — bạn muốn cài đặt và chạy toàn bộ workshop trên máy của chính mình, xuất phát từ một máy chưa từng cài gì liên quan đến lập trình (có trợ lý kỹ thuật hỗ trợ trực tiếp).
- **Phần B** — các bước thiết lập cơ bản (clone repo, cài CLI, xác thực) cần có trước khi làm Phần C.
- **Phần C** — làm việc với file CSV của riêng bạn (`my-data/` + `./load_custom_data.sh`), phần mở rộng được nhắc tới trong `README.md`.

Nếu bạn chỉ tham gia workshop chính qua Codespaces, bạn **không cần** đọc tài liệu này.

---

## Phần A — Cài đặt từ máy hoàn toàn mới (dành cho trợ lý kỹ thuật hỗ trợ trực tiếp)

Phần này viết cho một **trợ lý kỹ thuật** đọc/làm cùng một người tham gia không
rành kỹ thuật, trên một máy chưa từng cài gì liên quan đến lập trình. Đưa
từng lệnh, giải thích ngắn gọn nó làm gì, rồi chạy. Nếu máy đã có sẵn
Git/Node/v.v., bỏ qua bước tương ứng và chuyển thẳng sang Phần B.

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
7. Tiếp tục với Phần B bên dưới — thực hiện trong cửa sổ Ubuntu này.

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
4. Tiếp tục với Phần B bên dưới, trong cùng cửa sổ Terminal này.

Sau khi hoàn tất Windows hoặc macOS ở trên, làm theo đúng các bước trong Phần B
— không có gì khác biệt từ đây trở đi, dù đang ở Ubuntu-trong-WSL2 hay macOS.
Nếu có trục trặc trong lúc cài đặt, xem mục "Hỗ trợ cài đặt cục bộ" trong
`../organizers/FACILITATOR_TROUBLESHOOTING.md` — nhờ trợ lý kỹ thuật của bạn
mở tài liệu đó.

---

## Phần B — Các bước thiết lập cơ bản

### 1. Clone repo

```bash
git clone git@github.com:QuanPham99/CB_Txt2Sql.git
cd CB_Txt2Sql
```

Nếu bạn chưa cài Git LFS, hãy cài *trước* khi clone (hoặc chạy `git lfs pull` ngay sau đó):

```bash
git lfs install
git lfs pull
```

### 2. Xác nhận dữ liệu đã pull đúng

```bash
ls -la data/workshop.duckdb
```

Kỳ vọng một file thật, ~75MB. Nếu chỉ vài trăm byte, đó là một pointer LFS chưa được resolve — chạy lại `git lfs pull` rồi kiểm tra lại.

```bash
duckdb data/workshop.duckdb -c "SELECT count(*) FROM transactions;"
```

Nếu bạn chưa có DuckDB CLI, cài ngay bây giờ:

```bash
curl -fsSL https://install.duckdb.org | sh
export PATH="$HOME/.duckdb/cli/latest:$PATH"
echo 'export PATH="$HOME/.duckdb/cli/latest:$PATH"' >> ~/.bashrc   # hoặc ~/.zshrc
```

Kỳ vọng `2000000`.

### 3. Cài các CLI

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

### 4. Xác thực cả hai CLI

Từ thư mục gốc của repo:

```bash
claude
```
Làm theo URL đăng nhập được in ra, đăng nhập bằng tài khoản Claude.ai (hoặc dán một Anthropic API key cá nhân).

```bash
codex
```
Làm theo URL được in ra / prompt "Sign in with ChatGPT" (hoặc dán một OpenAI API key cá nhân).

Nếu một trong hai bị lặp vòng đăng nhập, nhờ trợ lý kỹ thuật của bạn xem mục "Hỗ trợ cài đặt cục bộ" trong `../organizers/FACILITATOR_TROUBLESHOOTING.md`.

Khi cả hai bước Clone repo, Xác nhận dữ liệu, Cài CLI, và Xác thực ở trên đã hoàn tất, bạn đã sẵn sàng cho Phần C bên dưới.

---

## Phần C — Dữ liệu tùy chỉnh cục bộ (CSV của riêng bạn)

Cần đã hoàn thành Phần B ở trên (repo đã clone, `claude`/`codex` đã xác thực).

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

## Tham khảo nhanh

| File | Mục đích |
|---|---|
| `../README.md` | Điểm vào chính của workshop |
| `../exercises.md` | Luồng bài tập chính (Codespaces) |
| `../schemas/BANK_DATASET_SCHEMA.md` | Từ điển dữ liệu ngân hàng |
| `../templates/custom-data-skill-template/` | Khung mẫu skill cho dữ liệu tùy chỉnh |
| `../load_custom_data.sh`, `../my-data/` | Script nạp CSV + nơi đặt file CSV của bạn (git-ignored) |
| `../organizers/FACILITATOR_TROUBLESHOOTING.md` | Xử lý sự cố cài đặt cục bộ (dành cho trợ lý kỹ thuật) |
| `../organizers/WORKSHOP_SETUP_GUIDE_LOCAL.md` | Phiên bản dry-run đầy đủ dành cho ban tổ chức (bao gồm cả luồng workshop chính chạy cục bộ) |
