# Xử Lý Sự Cố Cho Facilitator (không dành cho người tham gia)

Mở sẵn tài liệu này trên màn hình thứ hai trong suốt workshop. Cố tình không liên kết từ README — người tham gia không cần đến nó.

## Codespace bị kẹt khi build / rất chậm
- Xác nhận prebuild đã được bật và ở trạng thái xanh cho nhánh mặc định (repo → Settings → Codespaces → Prebuild configurations). Một cold build không có prebuild có thể mất vài phút và sẽ trông như "bị kẹt" đối với người tham gia.
- Bảo họ hủy và mở lại: **Code → Codespaces → "..." → Rebuild container**. Nếu thất bại hai lần, bảo họ xóa Codespace và tạo cái mới — các lớp cache cũ đôi khi bị hỏng.
- Nếu nhiều người cùng gặp tình trạng này một lúc, khả năng cao là các cold start đồng thời đang xếp hàng ở phía GitHub — lần sau hãy giãn cách hướng dẫn "mọi người cùng click ngay" (xem checklist ngày diễn ra).

## `claude` hoặc `codex` bị lặp vòng đăng nhập OAuth (trình duyệt bật lại mà không hoàn tất)
- Bảo họ thử luồng device-code thay vì popup trình duyệt, nếu CLI có hỗ trợ (`claude login --no-browser` / cờ tương đương của Codex) — cách này đáng tin cậy hơn trong thiết lập forwarded-browser của Codespaces.
- Kiểm tra xem tài khoản GitHub/Claude/OpenAI của họ có nằm sau SSO của tổ chức không — các tài khoản bị SSO chặn đôi khi cản trở redirect OAuth mà CLI sử dụng. Bảo họ thử tài khoản cá nhân (không phải tài khoản công ty) nếu có, hoặc dùng API key thay thế.
- Port forwarding của Codespaces đôi khi có thể chặn callback — thử chuyển visibility của port được forward sang "Public" tạm thời (tab Ports trong VS Code), thử lại, rồi đặt lại như cũ.

## `data/workshop.duckdb` bị thiếu hoặc rỗng
- `postCreateCommand` lẽ ra đã bắt được lỗi này và báo lỗi rõ ràng trong creation log của Codespace — kiểm tra log đó trước (Codespaces → Codespace đó → "..." → "View creation log").
- Nguyên nhân khả dĩ nhất: Git LFS chưa pull. Chạy thủ công trong terminal: `git lfs pull` rồi chạy lại `bash .devcontainer/postCreate.sh`.
- Kiểm tra nhanh số dòng: `duckdb data/workshop.duckdb -c "SELECT count(*) FROM transactions;"` phải trả về 2.000.000. Nếu trả về 0 hoặc báo lỗi "no such table," file đó là stub/pointer, không phải dữ liệu thật — đó chính là triệu chứng LFS ở trên.

## Rate limit / thông báo "please wait and try again" từ Claude hoặc ChatGPT
- Các gói miễn phí/thấp có thể chạm rate limit khi cả phòng 20–50 người cùng truy vấn một lúc. Cho người bị ảnh hưởng ghép cặp với người bên cạnh trong vài phút, hoặc chuyển sang xem màn hình demo chung.
- Chuẩn bị sẵn video màn hình dự phòng 2 phút của luồng chuẩn (xem Phần 3 của `WORKSHOP_SETUP_PLAN.md`) trong trường hợp tình trạng này lan rộng — phát video đó trong lúc chờ hồi phục thay vì để cả phòng chờ đợi.

## Extension VS Code không load (sidebar Claude Code / Codex bị thiếu)
- Extension cài đặt bất đồng bộ sau khi container báo "ready" — bảo họ chờ khoảng 30 giây rồi reload cửa sổ (`Cmd/Ctrl+Shift+P` → "Developer: Reload Window").
- Nếu vẫn thiếu, kiểm tra sidebar Extensions xem có lỗi cài đặt không, rồi cài thủ công từ marketplace như phương án dự phòng (extension ID nằm trong `.devcontainer/devcontainer.json`).

## Hỗ trợ cài đặt cục bộ (dành cho trợ lý kỹ thuật)

Chỉ áp dụng cho người tham gia chạy cục bộ (không dùng Codespaces) — xem
Phần A và Phần C của `../participants/LOCAL_SETUP_GUIDE.md` cho luồng đầy
đủ. Không có script tự động cho phần này — bạn (trợ lý kỹ thuật) là người
chạy cùng người tham gia, nên kiểm tra sau đây giúp bạn tự tin xác nhận từng
bước đã đúng trước khi chuyển sang bước kế.

**Kiểm tra đầu tiên, trước khi bắt đầu bất kỳ cài đặt nào:**
- Người tham gia có quyền Administrator (Windows) / có thể nhập mật khẩu máy
  (macOS) không? Cả hai luồng cài đặt đều cần quyền này ở ít nhất một bước.
- Máy có phải máy công ty bị khóa bởi chính sách IT (antivirus/EDR chặn chạy
  script, chặn `wsl --install`, chặn tải file qua `curl`) không? Nếu có, đây
  thường là giới hạn ở tầng chính sách, không sửa được từ phía người dùng —
  chuyển người đó sang dùng Codespaces thay vì cố tiếp tục cài cục bộ.
- Máy đã từng cài WSL (Windows) hoặc Homebrew (macOS) trước đây chưa? Nếu có,
  bỏ qua bước cài tương ứng trong Phần 0b, chỉ cần xác nhận `git`/`node` có
  sẵn (`git --version`, `node --version`) rồi đi thẳng vào "1. Clone repo".

**Các điểm hay vướng nhất, theo đúng thứ tự các bước trong Phần A của `../participants/LOCAL_SETUP_GUIDE.md`:**
- `wsl --install -d Ubuntu` báo lỗi ngay lập tức (không phải yêu cầu restart)
  → thường là do ảo hóa (virtualization) chưa bật trong BIOS/UEFI, hoặc máy
  đang chạy trong một VM lồng nhau. Đây là giới hạn phần cứng, không sửa
  được nhanh tại chỗ — chuyển người đó sang Codespaces.
- Sau khi restart, cửa sổ Ubuntu không tự mở → mở thủ công qua Start Menu,
  gõ "Ubuntu".
- `sudo apt install` báo lỗi mạng → kiểm tra Wi-Fi của địa điểm workshop có
  chặn một số domain không (một số mạng công ty/khách sạn có whitelist).
- macOS: script cài Homebrew treo ở bước nhập mật khẩu → đó là ô nhập mật
  khẩu ẩn (không hiện ký tự khi gõ, kể cả dấu `*`) — vẫn đang nhận input
  bình thường, chỉ cần gõ và nhấn Enter.
- `npm install -g @anthropic-ai/claude-code` báo lỗi quyền (permission
  denied) trên macOS/Linux → dấu hiệu Node.js được cài qua kênh cần `sudo`
  cho global install; bảo họ thử lại với `sudo npm install -g
  @anthropic-ai/claude-code`, hoặc cài lại Node qua `brew`/`nvm` để tránh
  cần `sudo` về sau.

**Trạng thái đúng khi hoàn tất** (để bạn xác nhận thay vì đoán):
- `./setup.sh` chạy xong không có dòng nào bắt đầu bằng `ERROR:`, và in ra
  banner "Setup complete! Next steps" ở cuối — giống hệt log mà
  `postCreate.sh` in ra trong Codespaces.
- Cả hai smoke test đều xuất hiện: `transactions table has 2000000 rows.`
  và ít nhất một dòng `<tên_bảng> table has <n> rows.` cho phía tech-salary.
- `claude --version` và `codex --version` đều chạy được (chưa cần đăng nhập
  ở bước này — đăng nhập là Bước 4 riêng).

## Phương án chung khi bí
Nếu hơn 2–3 người cùng gặp một vấn đề cùng lúc, dừng việc xử lý từng người và nói với cả phòng — nhiều khả năng đó là vấn đề hệ thống (prebuild chưa sẵn sàng, SSO của tổ chức chặn tất cả mọi người từ một công ty, v.v.), không phải vấn đề cá nhân.
