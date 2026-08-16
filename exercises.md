# Bài Tập Workshop

Làm theo cùng facilitator theo thời gian thực. Bạn cần `claude` hoặc `codex` đã được xác thực trong terminal (xem README) và mở sẵn `schemas/BANK_DATASET_SCHEMA.md` trong một tab.

## Bước 1 — Đọc ví dụ mẫu

Mở `.claude/skills/sql-helper/SKILL.md` (hoặc `.codex/skills/sql-helper/SKILL.md` — nội dung giống nhau). Đây là một **skill**: các chỉ dẫn bằng ngôn ngữ tự nhiên mà AI đọc trước khi trả lời, cho nó biết *cách* hành xử — nó tự xác định câu hỏi thuộc database nào (xem thư mục `schemas/`), dựa vào đúng file schema tương ứng, luôn hiển thị SQL đã chạy, luôn `LIMIT 100`, v.v. Ở bước này bạn sẽ chỉ hỏi về dữ liệu ngân hàng, nên skill sẽ tự chọn `schemas/BANK_DATASET_SCHEMA.md` / `data/workshop.duckdb` — phần chọn database sẽ rõ hơn ở Bước 7.

## Bước 2 — Đặt câu hỏi bằng ngôn ngữ tự nhiên

Mở terminal trong repo này và khởi động `claude` hoặc `codex`. Đặt câu hỏi đầu tiên của bạn:

> 5 danh mục giao dịch có tổng số tiền cao nhất trong quý vừa rồi là gì?

Quan sát nó đọc skill, viết SQL chạy trên `data/workshop.duckdb`, thực thi, và giải thích câu trả lời.

## Bước 3 — Thử lần lượt các câu hỏi sau

Bộ câu hỏi dưới đây chia làm 3 cấp độ tăng dần, dùng để kiểm tra xem skill (`SKILL.md`) xử lý tốt đến đâu — từ truy vấn một bảng đơn giản, đến join nhiều bảng, đến những câu đòi hỏi CTE/window function và suy luận nghiệp vụ thật sự. Đi từ trên xuống dưới; nếu câu trả lời có vẻ sai ở bất kỳ đâu, hãy yêu cầu AI hiển thị SQL nó đã chạy — thường lỗi sẽ lộ rõ ở đó.

### Cấp độ Cơ bản — một bảng, tổng hợp đơn giản

1. Chúng ta có bao nhiêu khách hàng, phân theo giới tính?
2. Số dư tài khoản trung bình của mỗi loại tài khoản (`account_type`) là bao nhiêu?
3. Có bao nhiêu ticket hỗ trợ đang ở trạng thái "Open," phân theo loại vấn đề?
4. Liệt kê 10 khoản vay (loan) có số tiền gốc (`loan_amount`) lớn nhất, kèm loại vay và trạng thái.
5. Trong số các giao dịch thẻ (`card_transactions`), bao nhiêu phần trăm bị đánh dấu gian lận (`is_fraud`)?

### Cấp độ Trung cấp — join 2 bảng, GROUP BY có điều kiện

1. Chi nhánh nào đã xử lý tổng số tiền giao dịch (`transactions`) cao nhất? (join `accounts` → `branches`)
2. Với các khách hàng gia nhập năm 2023, điểm tín dụng trung bình của họ so với khách hàng gia nhập năm 2015 như thế nào?
3. Tỷ lệ thanh toán trễ (`late_payment_flag`) trên tổng số lượt thanh toán là bao nhiêu, phân theo từng loại khoản vay (`loan_type`)?
4. 10 khách hàng nào mở nhiều ticket hỗ trợ nhất, và loại vấn đề (`issue_type`) phổ biến nhất của mỗi người là gì?
5. Bao nhiêu phần trăm giao dịch thẻ bị đánh dấu gian lận, phân theo loại thẻ (`card_type`) thay vì theo danh mục merchant?

### Cấp độ Nâng cao — nhiều bảng, CTE/window function, suy luận nghiệp vụ

Các câu này cố tình phức tạp — không có một câu SQL "đúng" duy nhất, mục tiêu là xem skill có tự chia nhỏ vấn đề (CTE), chọn đúng cột để join, và nêu rõ giả định hay không.

1. **Xếp hạng rủi ro khách hàng:** với mỗi khách hàng đang có ít nhất một khoản vay ở trạng thái "Active" hoặc "Defaulted", tính: tổng số tiền đã thanh toán (`loan_payments`), tỷ lệ thanh toán trễ, điểm tín dụng (`credit_score`), và số ticket loại "Fraud Report" họ từng mở. Xếp hạng 20 khách hàng rủi ro cao nhất theo tiêu chí kết hợp cả 4 yếu tố trên, và yêu cầu AI giải thích rõ cách nó tính điểm rủi ro.
2. **Tăng trưởng theo tháng:** tính tổng số tiền giao dịch (`transactions.amount`) theo từng tháng, rồi tính phần trăm tăng/giảm so với tháng liền trước (window function kiểu `LAG`) cho 24 tháng gần nhất — tính "gần nhất" theo `MAX(txn_date)` thực tế trong bảng, không phải ngày hôm nay.
3. **Top khách hàng theo tổng giá trị giao dịch:** trong số khách hàng có ít nhất một tài khoản "Active", tìm nhóm 5% khách hàng có tổng giá trị giao dịch cao nhất — cộng cả giao dịch cấp tài khoản (`transactions`) lẫn giao dịch cấp thẻ (`card_transactions`) theo đúng từng khách hàng, **không** `UNION` trực tiếp hai bảng vì chúng khác grain (xem phần "Lưu ý & điểm đặc biệt" trong từ điển dữ liệu). Sau đó cho biết chi nhánh nào đang phục vụ nhiều khách hàng thuộc nhóm 5% này nhất.
4. **Nợ xấu theo chi nhánh so với nhân sự:** với mỗi chi nhánh, tính tỷ lệ nợ xấu (khoản vay ở trạng thái "Defaulted" hoặc "Written Off" trên tổng số khoản vay của chi nhánh đó), rồi so sánh với số lượng nhân viên có vai trò "Loan Officer" đang làm việc tại chi nhánh — chi nhánh nào có tỷ lệ nợ xấu cao bất thường so với số Loan Officer hiện có?

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

Đặt lại một vài câu hỏi từ Bước 3 (mỗi cấp độ một câu là đủ), hoặc một câu hỏi mới. Xác nhận rằng hành vi của AI giờ đã tuân theo quy tắc của bạn — đặc biệt ở các câu Nâng cao, đây là nơi dễ thấy rõ nhất liệu skill của bạn có giúp AI xử lý tốt hơn các truy vấn phức tạp hay không. Đó chính là khoảnh khắc "à ha": bạn chỉ viết ngôn ngữ tự nhiên, không phải code, mà nó đã thay đổi cách AI hành xử.

Muốn tự đối chiếu kết quả của Bước 3 với một đáp án tham khảo? Xem `participants/exercises_answer_key.ipynb`.

## Bước 6 — Chia sẻ kết quả

Một vài tình nguyện viên trình bày file skill của mình và demo một câu hỏi/câu trả lời trực tiếp cho cả nhóm.

## Bước 7 (tùy chọn) — Mở rộng: bộ dữ liệu Tech Salary

Bài tập nhanh này không dạy kỹ năng mới — nó chứng minh rằng skill bạn vừa xây ở
Bước 4 áp dụng được cho một bộ dữ liệu hoàn toàn khác, không chỉ riêng dữ liệu
ngân hàng. Có một database DuckDB thứ hai, độc lập với database ngân hàng:
`data/tech_salary.duckdb`. Đây cũng chính xác là kỹ thuật mà skill mẫu
`sql-helper` bạn đọc ở Bước 1 đã dùng — nó tự chọn đúng database dựa vào chủ đề
câu hỏi thay vì gắn cứng với một database duy nhất. Bây giờ bạn sẽ tự tay thêm
kỹ thuật đó vào skill của chính mình.

1. Mở `schemas/TECH_SALARY_DATASET_SCHEMA.md` — từ điển dữ liệu cho
   `data/tech_salary.duckdb`, cùng định dạng với `schemas/BANK_DATASET_SCHEMA.md`.
   (Cả hai file schema của workshop đều nằm trong thư mục `schemas/`.)
2. **Mở rộng chính skill bạn đã xây ở Bước 4** (`.claude/skills/<tên-của-bạn>/SKILL.md`)
   — không tạo skill mới. Sửa để nó:
   - Cũng tự "ground" vào `schemas/TECH_SALARY_DATASET_SCHEMA.md`, bên cạnh
     `schemas/BANK_DATASET_SCHEMA.md` đã có. (Gợi ý: đọc lại cách
     `.claude/skills/sql-helper/SKILL.md` mô tả bước "Xác định đúng database"
     nếu bạn muốn tham khảo — không bắt buộc phải làm giống hệt.)
   - Có thêm một quy tắc để tự xác định: câu hỏi đang hỏi đang nói về dữ liệu
     nào — nếu về ngân hàng thì truy vấn `data/workshop.duckdb`, nếu về lương
     ngành công nghệ thì truy vấn `data/tech_salary.duckdb`.
   - Kỹ thuật để làm việc với cả hai database trong cùng một skill (chạy hai
     lệnh `duckdb <file> -c "..."` riêng biệt, hay dùng `ATTACH` để mở cả hai
     cùng lúc) — không quy định trước, tự bạn quyết định cách nào phù hợp.
3. Đặt các câu hỏi sau bằng ngôn ngữ tự nhiên (đừng gõ SQL trực tiếp — để skill
   tự sinh SQL) và xác nhận skill của bạn chọn đúng database
   (`data/tech_salary.duckdb`, không phải `data/workshop.duckdb`) cho từng câu,
   vẫn tuân theo các quy tắc riêng bạn đã viết ở Bước 4 dù đang chạy trên schema
   mới:
   - "Mức lương trung bình cho vị trí Data Scientist là bao nhiêu?" (gợi ý đáp
     án: ~122.723 USD, tính trên trung bình `salary_min_usd`/`salary_max_usd`,
     gộp cả hai bảng, 769 tin đăng)
   - "3 tổ hợp công nghệ (tech_stack) xuất hiện trong nhiều tin đăng nhất là
     gì?" (gợi ý đáp án: `Java, Spring Boot, Kafka, PostgreSQL` (1.555 tin),
     `Rust, WebAssembly, System Architecture` (1.548 tin), `Ruby on Rails,
     Redis, Heroku` (1.528 tin))
   - "So sánh mức lương tối đa trung bình giữa tin đăng từ USAJOBS và toàn bộ
     thị trường tech nói chung" (gợi ý đáp án: USAJOBS ~143.374 USD so với
     ~141.565 USD trên toàn bộ `global_tech_market_2026` — khá gần nhau)

> Gợi ý mở rộng sau workshop (không phải bài tập, không có trong repo này):
> skill của bạn cũng có thể học cách nối nhiều truy vấn lại thành một bản tóm
> tắt/insight report bằng ngôn ngữ tự nhiên — đó là hướng để bạn tự phát triển
> tiếp, không phải nội dung của buổi hôm nay.
