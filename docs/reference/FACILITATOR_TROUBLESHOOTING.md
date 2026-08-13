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
- Chuẩn bị sẵn video màn hình dự phòng 2 phút của luồng chuẩn (xem Phần 3 của `../setup/WORKSHOP_SETUP_PLAN.md`) trong trường hợp tình trạng này lan rộng — phát video đó trong lúc chờ hồi phục thay vì để cả phòng chờ đợi.

## Extension VS Code không load (sidebar Claude Code / Codex bị thiếu)
- Extension cài đặt bất đồng bộ sau khi container báo "ready" — bảo họ chờ khoảng 30 giây rồi reload cửa sổ (`Cmd/Ctrl+Shift+P` → "Developer: Reload Window").
- Nếu vẫn thiếu, kiểm tra sidebar Extensions xem có lỗi cài đặt không, rồi cài thủ công từ marketplace như phương án dự phòng (extension ID nằm trong `.devcontainer/devcontainer.json`).

## Phương án chung khi bí
Nếu hơn 2–3 người cùng gặp một vấn đề cùng lúc, dừng việc xử lý từng người và nói với cả phòng — nhiều khả năng đó là vấn đề hệ thống (prebuild chưa sẵn sàng, SSO của tổ chức chặn tất cả mọi người từ một công ty, v.v.), không phải vấn đề cá nhân.
