# Bài Tập Workshop

Làm theo cùng facilitator theo thời gian thực. Bạn cần `claude` hoặc `codex` đã được xác thực trong terminal (xem README) và mở sẵn `SCHEMA.md` trong một tab.

## Bước 1 — Đọc ví dụ mẫu

Mở `.claude/skills/sql-helper/SKILL.md` (hoặc `.codex/skills/sql-helper/SKILL.md` — nội dung giống nhau). Đây là một **skill**: các chỉ dẫn bằng ngôn ngữ tự nhiên mà AI đọc trước khi trả lời, cho nó biết *cách* hành xử (dựa vào `SCHEMA.md`, luôn hiển thị SQL đã chạy, luôn `LIMIT 100`, v.v.).

## Bước 2 — Đặt câu hỏi bằng ngôn ngữ tự nhiên

Mở terminal trong repo này và khởi động `claude` hoặc `codex`. Đặt câu hỏi đầu tiên của bạn:

> 5 danh mục giao dịch có tổng số tiền cao nhất trong quý vừa rồi là gì?

Quan sát nó đọc skill, viết SQL chạy trên `data/workshop.duckdb`, thực thi, và giải thích câu trả lời.

## Bước 3 — Thử lần lượt các câu hỏi sau

Mỗi câu sẽ phức tạp hơn một chút so với câu trước.

1. Chúng ta có bao nhiêu khách hàng, phân theo nghề nghiệp?
2. Số dư tài khoản trung bình của mỗi loại tài khoản là bao nhiêu?
3. Chi nhánh nào đã xử lý tổng số tiền giao dịch cao nhất?
4. Có bao nhiêu ticket hỗ trợ đang ở trạng thái "Open," phân theo loại vấn đề?
5. Bao nhiêu phần trăm giao dịch thẻ bị đánh dấu gian lận, phân theo danh mục merchant?
6. 10 khách hàng nào đã trả tổng số tiền lãi vay nhiều nhất?
7. Với các khách hàng gia nhập năm 2023, điểm tín dụng trung bình của họ so với khách hàng gia nhập năm 2015 như thế nào?
8. Tìm các tài khoản có số dư thấp hơn số tiền rút trung bình hàng tháng trong 6 tháng dữ liệu gần nhất (đây là các tài khoản có nguy cơ thấu chi).

Nếu câu trả lời có vẻ sai, hãy yêu cầu AI hiển thị SQL nó đã chạy — thường lỗi sẽ lộ rõ ở đó.

## Bước 4 — Tự xây dựng skill của bạn

1. Sao chép template: `templates/skill-template/SKILL.md` → một folder mới `.claude/skills/<tên-của-bạn>/SKILL.md`.
2. Nhân bản sang `.codex/skills/<tên-của-bạn>/SKILL.md` (copy hoặc symlink, giống như ví dụ mẫu).
3. Điền vào các phần `TODO` với 3–5 dòng chỉ dẫn thể hiện một quy tắc **do bạn chọn**. Một vài gợi ý:
   - "Luôn giải thích câu truy vấn bằng một câu ngôn ngữ tự nhiên trước khi hiển thị SQL."
   - "Luôn làm tròn tiền tệ về 2 chữ số thập phân và thêm ký hiệu $ hoặc ₫."
   - "Luôn sắp xếp kết quả theo ngày giảm dần trừ khi được yêu cầu khác."
   - "Không bao giờ trả về quá 20 dòng nếu không được yêu cầu."
   - "Luôn đề cập bảng nào đã được dùng để trả lời."

## Bước 5 — Kiểm thử

Đặt lại câu hỏi từ Bước 2, hoặc một câu hỏi mới. Xác nhận rằng hành vi của AI giờ đã tuân theo quy tắc của bạn. Đó chính là khoảnh khắc "à ha": bạn chỉ viết ngôn ngữ tự nhiên, không phải code, mà nó đã thay đổi cách AI hành xử.

## Bước 6 — Chia sẻ kết quả

Một vài tình nguyện viên trình bày file skill của mình và demo một câu hỏi/câu trả lời trực tiếp cho cả nhóm.
