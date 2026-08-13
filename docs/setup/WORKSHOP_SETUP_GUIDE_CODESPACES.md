# Hướng Dẫn Thiết Lập Workshop — Kiểm Thử Qua GitHub Codespaces

Một hướng dẫn từng bước, thực tế, để khởi chạy **chính repo này** trong một GitHub Codespace thật và xác nhận toàn bộ workshop hoạt động trơn tru từ đầu đến cuối — trước khi bạn đưa nó cho 20–50 người tham gia.

Đây là tài liệu đồng hành "môi trường thật" của `WORKSHOP_SETUP_GUIDE_LOCAL.md` và `Iteration_0_LocalTesting.md` (những tài liệu chạy workshop trên máy của chính bạn để nhanh chóng bắt lỗi script/skill mà không cần GitHub). Những thứ đặc thù của Codespaces — redirect OAuth, pull Git LFS qua mạng, prebuild, giới hạn chi tiêu — *chỉ* có thể được kiểm chứng ở đây, không phải cục bộ. Hãy chạy thử cục bộ trước nếu bạn chưa làm; rồi mới làm bước này.

> Repo: `QuanPham99/CB_Txt2Sql` (remote `origin`, nhánh `main` — đã xác nhận push và cập nhật tính đến thời điểm viết hướng dẫn này).

---

## 0. Điều kiện tiên quyết (ban tổ chức)

- [ ] Một tài khoản GitHub có quyền truy cập `QuanPham99/CB_Txt2Sql` (quyền owner nếu bạn sẽ thay đổi cài đặt repo/Codespaces).
- [ ] Một **tài khoản Claude.ai** có gói đang hoạt động (Pro/Max), hoặc một API key Anthropic cá nhân.
- [ ] Một **tài khoản ChatGPT** có quyền truy cập Codex (Plus/Pro/Business/Edu), hoặc một API key OpenAI cá nhân.
- [ ] `data/workshop.duckdb` được theo dõi qua Git LFS và đã push lên `origin/main` (`git lfs ls-files` phải liệt kê nó; đã xác nhận có mặt cục bộ ở khoảng 75MB).

---

## 1. Mở một Codespace đúng như một người tham gia sẽ làm

Đừng tái sử dụng một Codespace dev đã có — các lớp cache cũ có thể che giấu một `postCreateCommand` bị hỏng.

1. Truy cập `https://github.com/QuanPham99/CB_Txt2Sql`.
2. **Code → Codespaces → Create codespace on main** (hoặc click badge "Open in GitHub Codespaces" trong `README.md`).
3. Theo dõi creation log (Codespaces → Codespace của bạn → "..." → **View creation log**). Bạn đang xem `.devcontainer/postCreate.sh` chạy trực tiếp:
   - Cài DuckDB CLI
   - `npm install -g @anthropic-ai/claude-code`
   - Cài Codex CLI
   - Chạy smoke test dữ liệu — nó phải in ra `Smoke test: transactions table has 2000000 rows.` rồi `== Setup complete ==`
4. **Nếu log hiện lỗi và build thất bại**, dừng lại ngay và sửa lỗi (xem `../reference/FACILITATOR_TROUBLESHOOTING.md` → "`data/workshop.duckdb` missing or empty") trước khi làm bất cứ điều gì khác — một `postCreateCommand` bị hỏng sẽ thất bại y hệt với mọi người tham gia.
5. Khi Codespace mở lên, bạn sẽ thấy banner chào mừng của `postAttach.sh` được in trong terminal:
   ```
   ========================================================
    Welcome to the Text-to-SQL Skills Workshop!
    1. Read BANK_DATASET_SCHEMA.md to see what's in the dataset.
    2. Authenticate:  claude   /   codex
    3. Follow exercises.md to get started.
   ========================================================
   ```

**Đo thời gian bước này.** Ghi lại thời gian thực tế từ lúc click "Create codespace" đến khi banner xuất hiện — bạn sẽ cần con số này cho agenda ngày diễn ra (xem `../reference/DAY_OF_CHECKLIST.md`).

---

## 2. Xác nhận dữ liệu đã nạp đúng

Trong terminal tích hợp:

```bash
duckdb data/workshop.duckdb -c "SELECT count(*) FROM transactions;"
```

Kết quả mong đợi là `2000000`. Nếu là `0`, báo lỗi, hoặc file có vẻ rất nhỏ (vài trăm byte = một LFS pointer chưa được resolve, không phải dữ liệu thật), hãy chạy:

```bash
git lfs pull
bash .devcontainer/postCreate.sh
```

rồi kiểm tra lại. Đây là kiểu lỗi dễ gặp trên Codespaces nhưng lại vô hình ở cục bộ nếu bạn đã có sẵn file trong cache — hãy xem đây là điều chính mà hướng dẫn này tồn tại để bắt lỗi.

---

## 3. Xác thực cả hai CLI

```bash
claude
```
Làm theo URL đăng nhập được in ra, đăng nhập bằng tài khoản Claude.ai của bạn (hoặc dán một API key Anthropic cá nhân).

```bash
codex
```
Làm theo URL được in ra / lời nhắc "Sign in with ChatGPT" (hoặc dán một API key OpenAI cá nhân).

**Cần chú ý:** đây là bước có khả năng cao nhất sẽ hoạt động khác so với bài kiểm thử Docker cục bộ của bạn — đường OAuth forwarded-browser của Codespaces khác với `localhost`. Nếu trình duyệt bật lại mà không hoàn tất đăng nhập:
- Thử luồng device-code nếu CLI có hỗ trợ.
- Kiểm tra xem tài khoản GitHub/Claude/OpenAI của bạn có nằm sau SSO của tổ chức không — thử một tài khoản cá nhân thay thế.
- Kiểm tra tab **Ports** trong VS Code — tạm thời đặt visibility của port xác thực được forward thành "Public," thử lại, rồi đặt lại như cũ.

(Chi tiết đầy đủ trong `../reference/FACILITATOR_TROUBLESHOOTING.md`.)

---

## 4. Xác nhận các extension VS Code đã load

Kiểm tra sidebar Extensions (hoặc chỉ cần thử dùng chúng):
- [ ] Extension Claude Code (`anthropic.claude-code`)
- [ ] Extension Codex (`openai.chatgpt`)
- [ ] `evidence.sqltools-duckdb-driver` + `mtxr.sqltools` — cho phép duyệt các bảng trong `data/workshop.duckdb` từ sidebar

Extension cài đặt bất đồng bộ sau khi container báo "ready." Nếu thiếu một cái, hãy chờ khoảng 30 giây rồi reload cửa sổ (`Cmd/Ctrl+Shift+P` → "Developer: Reload Window") trước khi kết luận là nó thất bại.

---

## 5. Lướt qua data dictionary

```bash
code BANK_DATASET_SCHEMA.md   # hoặc mở trực tiếp trong editor
```

Đây là bước "hiểu dữ liệu" duy nhất mà một người tham gia cần — xác nhận nó vẫn mô tả chính xác `data/workshop.duckdb` (tên bảng, số dòng, các cột, các điểm đặc biệt). Nếu bạn đã chỉnh sửa dataset kể từ khi tài liệu này được viết, hãy cập nhật `BANK_DATASET_SCHEMA.md` ngay bây giờ.

---

## 6. Kiểm thử skill mẫu

Mở `.claude/skills/sql-helper/SKILL.md` (và xác nhận `.codex/skills/sql-helper/SKILL.md` mirror đúng) để bạn biết mình đang kiểm tra hành vi gì. Sau đó, trong `claude` (và lặp lại trong `codex`), hỏi:

> What were the top 5 transaction categories by total amount last quarter?

Xác nhận nó:
- [ ] Dựa vào `BANK_DATASET_SCHEMA.md` (không bịa ra tên cột)
- [ ] Hiển thị câu SQL đã chạy
- [ ] Áp dụng các quy tắc trong `SKILL.md` (ví dụ `LIMIT 100` trên raw rows, làm tròn tiền tệ)
- [ ] Thực sự truy vấn `data/workshop.duckdb` và trả về số liệu thật

---

## 7. Làm qua các bài tập

```bash
code exercises.md
```

Tự chạy qua tất cả các câu hỏi mẫu, theo thứ tự, trong Codespace thật này. Nếu câu trả lời nào có vẻ sai hoặc model bịa ra tên cột/bảng, hãy sửa `SKILL.md` hoặc `BANK_DATASET_SCHEMA.md` ngay bây giờ — không phải trong buổi workshop trực tiếp.

---

## 8. Xây một skill tùy chỉnh dùng thử

Đây là Bước 3–4 của luồng workshop thật — hãy tự thử trước:

1. Sao chép `templates/skill-template/SKILL.md` vào một thư mục mới, ví dụ `.claude/skills/scratch-test/`.
2. Điền 2–3 quy tắc (ví dụ "luôn giải thích câu truy vấn trong một câu").
3. Đặt lại câu hỏi và xác nhận hành vi thay đổi rõ rệt.
4. Xóa thư mục nháp khi xong (đừng commit nó).

Nếu điều này gây khó hiểu hoặc lằng nhằng với bạn, nó sẽ gây khó hiểu cho một người tham gia không có kỹ thuật — hãy đơn giản hóa `templates/skill-template/SKILL.md` nếu vậy.

---

## 9. Dọn dẹp

Codespaces tự động dừng sau một khoảng thời gian không hoạt động, nhưng để dọn dẹp rõ ràng:

**GitHub → Settings → Codespaces**, hoặc từ repo: **Code → Codespaces → "..." → Delete**.

Bạn không bị tính phí compute cho một Codespace đã dừng, chỉ tính phí lưu trữ — hãy xóa các Codespace thử nghiệm không còn cần dùng để tránh bừa bộn.

---

## 10. Trước khi mở cho người tham gia thật

Khi các bước 1–9 đều đạt trơn tru trong một Codespace mới:

- [ ] Bật **Codespaces prebuilds** cho `main` (repo → Settings → Codespaces → Set up prebuild) để người tham gia nhận được container đã sẵn sàng thay vì một cold build kéo dài nhiều phút. Làm việc này trước một hoặc hai ngày, khớp với nơi phần lớn người tham gia đang ở.
- [ ] Đặt **giới hạn chi tiêu Codespaces** phù hợp với số người tham gia dự kiến × nửa ngày sử dụng (org/repo → Settings → Billing → Codespaces spending limit).
- [ ] Xác nhận Codespaces được bật cho loại tài khoản mà người tham gia sẽ thực sự dùng — tài khoản cá nhân hoạt động sẵn; tài khoản work/enterprise có thể cần admin của tổ chức bật lên. Nêu rõ điều này trong thông báo trước workshop nếu liên quan.
- [ ] Quay lại video màn hình dự phòng khoảng 2 phút của luồng chuẩn này trong trường hợp demo trực tiếp gặp sự cố vào ngày diễn ra.
- [ ] Chuyển sang `../reference/DAY_OF_CHECKLIST.md` cho phần hậu cần còn lại trước workshop và ngày diễn ra.

---

## Tra cứu nhanh — cái gì nằm ở đâu

| File | Mục đích |
|---|---|
| `README.md` | Điểm vào cho người tham gia, badge Codespaces một cú click |
| `BANK_DATASET_SCHEMA.md` | Data dictionary mà AI dựa vào |
| `exercises.md` | Luồng hướng dẫn trong workshop + câu hỏi mẫu |
| `.claude/skills/sql-helper/`, `.codex/skills/sql-helper/` | Skill mẫu (đã mirror) |
| `templates/skill-template/` | Khung sườn trống cho "tự xây skill của bạn" |
| `.devcontainer/` | Định nghĩa môi trường Codespaces |
| `data/workshop.duckdb` | DB đã nạp sẵn (Git LFS) — dữ liệu duy nhất người tham gia chạm vào |
| `docs/setup/WORKSHOP_SETUP_PLAN.md` | Bối cảnh/lý do đầy đủ cho ban tổ chức về tất cả những điều trên |
| `docs/reference/DAY_OF_CHECKLIST.md` | Checklist hậu cần trước workshop và ngày diễn ra |
| `docs/reference/FACILITATOR_TROUBLESHOOTING.md` | Xử lý sự cố trong buổi trực tiếp (chỉ dành cho facilitator) |
| `docs/setup/WORKSHOP_SETUP_GUIDE_LOCAL.md` | Chạy workshop trực tiếp trên máy của bạn, không cần GitHub/Codespaces |
| `docs/setup/Iteration_0_LocalTesting.md` | Phiên bản cục bộ dựa trên Docker/devcontainer tương đương hướng dẫn này |
