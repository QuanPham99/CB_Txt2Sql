# Checklist Cho Ban Tổ Chức — Chạy Thử & Hậu Cần Ngày Diễn Ra

Tài liệu đi kèm Phần 3 của `WORKSHOP_SETUP_PLAN.md`. Các mục đánh dấu **[THỦ CÔNG]** diễn ra trên website của GitHub hoặc trong một buổi trực tiếp, không thể thực hiện từ repo này — chúng được liệt kê ở đây để không bị bỏ sót.

## Vài ngày trước

- [ ] **[THỦ CÔNG]** Bật Codespaces prebuilds cho nhánh mặc định: repo → Settings → Codespaces → Set up prebuild. Chọn (các) vùng prebuild khớp với nơi phần lớn người tham gia đang ở.
- [ ] **[THỦ CÔNG]** Đặt giới hạn chi tiêu Codespaces phù hợp cho 20–50 người × nửa ngày sử dụng: org/repo → Settings → Billing → Codespaces spending limit.
- [ ] **[THỦ CÔNG]** Xác nhận Codespaces được bật cho loại tài khoản mà người tham gia sẽ dùng — tài khoản GitHub cá nhân hoạt động sẵn; tài khoản work/enterprise có thể cần admin của tổ chức bật lên. Nêu rõ điều này trong thông báo trước workshop nếu có người tham gia dùng tài khoản work.
- [ ] **[THỦ CÔNG]** Tạo một Codespace mới từ repo đúng như một người tham gia sẽ làm (đừng tái sử dụng Codespace dev của bạn). Đo thời gian toàn bộ luồng từ đầu đến cuối: container start → đăng nhập `claude`/`codex` → truy vấn thành công đầu tiên. Sửa bất cứ điều gì chậm hoặc gây khó hiểu trước khi tiếp tục.
- [ ] Xác nhận cả hai CLI xác thực trơn tru qua OAuth với một tài khoản cá nhân/thử nghiệm. Nếu có thể, thử trên cả trình duyệt Mac và Windows — WSL/Windows đôi khi gặp hành vi chuyển hướng OAuth khác nhau. Xem `FACILITATOR_TROUBLESHOOTING.md` nếu bị lặp vòng đăng nhập.
- [ ] **[THỦ CÔNG]** Quay lại màn hình khoảng 2 phút cho luồng chuẩn (mở Codespace → đăng nhập → đặt câu hỏi → nhận câu trả lời) làm phương án dự phòng trong trường hợp demo trực tiếp hoặc mạng của ai đó gặp sự cố.
- [ ] **[THỦ CÔNG]** Gửi email/tin nhắn Slack trước workshop gồm: link repo, checklist "trước khi đến" (tài khoản GitHub sẵn sàng; tài khoản Claude.ai có gói đang hoạt động hoặc API key; tài khoản ChatGPT có quyền truy cập Codex hoặc API key; trình duyệt đã đăng nhập cả hai), và thời gian build Codespace dự kiến.

## Ngày diễn ra

- [ ] **[THỦ CÔNG]** Giãn cách các lượt click "Open in Codespaces" một hoặc hai phút trong phòng/buổi gọi — 50 lượt cold start đồng thời có thể xếp hàng dù đã prebuild sẵn. Chia agenda thành "mọi người mở Codespace ngay bây giờ" và, vài phút sau, "mọi người đăng nhập ngay bây giờ."
- [ ] Mở sẵn `FACILITATOR_TROUBLESHOOTING.md` trên màn hình thứ hai.
- [ ] Chuẩn bị sẵn video màn hình dự phòng để phát nếu demo trực tiếp bị treo.

## Kiểm tra trước workshop (thực hiện sau khi chạy thử ở trên)

- [ ] Codespace mới xác nhận `SELECT count(*) FROM transactions;` trong `data/workshop.duckdb` trả về 2.000.000 (smoke test của `postCreateCommand` cũng nên tự động bắt lỗi này trong creation log).
- [ ] Cả `claude` và `codex` đều xác thực được qua OAuth.
- [ ] Cả hai extension VS Code (Claude Code, Codex) đều load được trong Codespace.
- [ ] Skill mẫu (`.claude/skills/sql-helper/SKILL.md`) thay đổi rõ rệt hành vi của model khi thử với một câu hỏi mẫu từ `exercises.md`.
- [ ] Thời gian từ cold-open đến câu truy vấn đầu tiên nằm gọn trong khối mở đầu của agenda nửa ngày.
