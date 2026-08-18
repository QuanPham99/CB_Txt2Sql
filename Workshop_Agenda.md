# Lịch trình Workshop: Hiểu dữ liệu → Truy vấn → Tạo insight

## Vì sao workshop này tồn tại

Rất nhiều người — kể cả dân kỹ thuật — không thể tự phục vụ (self-serve) khi gặp một bộ dữ liệu mới. Có ba điểm nghẽn lặp đi lặp lại:

1. **Không biết dữ liệu có gì** — không có schema, không có data dictionary, không biết hỏi ai.
2. **Biết schema rồi nhưng không viết được SQL** để trả lời một câu hỏi nghiệp vụ cụ thể.
3. **Có kết quả truy vấn rồi nhưng không biến nó thành thứ người khác đọc được** — một đống số không tự nó nói lên "vậy thì sao."

Workshop này dạy cách giải quyết cả ba điểm nghẽn trên bằng Claude Skill / Codex Skill — tức là chỉ cần viết hướng dẫn bằng ngôn ngữ tự nhiên (`SKILL.md`), không cần viết code.

**Khung sườn của cả buổi:** Hiểu dữ liệu → Truy vấn → Diễn giải → (mở rộng) Kết nối thành một chuỗi.

---

## Tổng quan thời lượng

Buổi workshop nửa ngày (~3h55 phần lõi + tối đa 20 phút phần mở rộng tùy chọn).

| # | Phần | Thời lượng | Ghi chú |
|---|------|-----------|---------|
| 0 | Mở đầu & đặt vấn đề | 15 phút | |
| 0.5 | Thuật ngữ cơ bản & Cheat sheet lệnh | 10 phút | mới |
| 1 | Nền tảng: đọc skill mẫu, hỏi câu đầu tiên | 20 phút | tương ứng Bước 1–2 trong `WORKSHOP_EXERCISES.md` |
| 2 | Thực hành: tự xây skill Text-to-SQL (Skill 1) — Bài tập 1: Bank Transaction Schema | 75 phút | tương ứng Bước 3–6 trong `WORKSHOP_EXERCISES.md` |
| — | Giải lao | 10 phút | |
| 3 | Skill 0 — dạy agent tự đọc hiểu một database chưa từng thấy | 40 phút | mới |
| 4 | Skill 2 — dạy agent biến kết quả truy vấn thành báo cáo insight | 35 phút | mới |
| 5 | *(tùy chọn, nếu còn thời gian)* Skill 4 — ghép schema → query → report thành một chuỗi; hoặc Bài tập 2 (Salary Schema) có sẵn | 15–20 phút | mới, có thể cắt |
| 6 | Demo & tổng kết | 15–20 phút | tương ứng Bước 6 trong `WORKSHOP_EXERCISES.md` |

Phần 5 là phần đầu tiên bị cắt nếu thiếu thời gian — nó được thiết kế là bài mở rộng, không phải nội dung bắt buộc.

---

## Phần 0 — Mở đầu & đặt vấn đề (15 phút)

- Mở bằng câu hỏi thực tế: "Ai từng cần một con số từ database và phải chờ kỹ sư lấy giúp?" — dẫn vào ba điểm nghẽn ở trên.
- Giới thiệu khung sườn 3(+1) skill của cả ngày: Hiểu → Truy vấn → Diễn giải → (mở rộng) Kết nối.
- Nói rõ kỳ vọng: Skill 1 (buổi sáng) có đầy đủ "bánh xe phụ" — skill mẫu, template, đáp án. Skill 0 và Skill 2 (buổi chiều) chỉ nhận một đề bài ngắn, không có template sẵn — tự thiết kế hướng dẫn cho agent, cùng một kỹ năng nhưng ít cầm tay chỉ việc hơn.

## Phần 0.5 — Thuật ngữ cơ bản & Cheat sheet lệnh (10 phút, mới)

Phát trước cho người tham gia như tài liệu tham khảo (giấy hoặc file), dùng lại xuyên suốt cả buổi — không cần giải thích hết trong 10 phút, chỉ điểm nhanh những từ sẽ gặp ngay ở Phần 1.

### Thuật ngữ cơ bản

| Thuật ngữ | Giải thích ngắn gọn |
|---|---|
| **LLM** (Large Language Model) | Mô hình ngôn ngữ lớn — "bộ não" đứng sau Claude và Codex, hiểu và sinh ra ngôn ngữ tự nhiên lẫn code. |
| **Agent** | Một LLM được cho phép tự hành động — tự quyết định chạy lệnh, đọc/ghi file, gọi công cụ — để hoàn thành một nhiệm vụ, chứ không chỉ trả lời một câu hỏi rồi dừng. |
| **CLI** (Command-Line Interface) | Công cụ chạy trong terminal bằng dòng lệnh, thay vì giao diện web/click chuột. Ở đây là hai lệnh `claude` và `codex`. |
| **Skill** | Một "gói hướng dẫn" viết bằng ngôn ngữ tự nhiên (file `SKILL.md`) dạy agent cách làm tốt một việc cụ thể, lặp lại được — ví dụ: cách trả lời câu hỏi SQL đúng quy tắc của bạn. |
| **SKILL.md / frontmatter** | Cấu trúc file của một Skill: phần **frontmatter** ở đầu file (`name`, `description`) giúp agent biết *khi nào* nên dùng skill này; phần thân file là hướng dẫn chi tiết *làm sao* để thực hiện. |
| **Prompt** | Câu lệnh/câu hỏi bằng ngôn ngữ tự nhiên bạn gửi cho agent. |
| **Schema / Data dictionary** | Tài liệu mô tả cấu trúc một database: có bảng nào, cột nào, kiểu dữ liệu gì, giá trị hợp lệ ra sao. Trong workshop này là các file `schemas/*.md`. |
| **DuckDB** | Công cụ database dùng trong workshop, thao tác qua CLI riêng của nó (`duckdb <file>.duckdb -c "SQL..."`) — khác với CLI của Claude/Codex. |
| **Devcontainer / Codespaces** | Môi trường phát triển đóng gói sẵn (chạy trên máy bạn hoặc trên GitHub) để mọi người có cùng một setup, không phải cài đặt thủ công từng phần. |
| **Context / Context window** | "Bộ nhớ làm việc" của agent trong một phiên trò chuyện — càng nhiều nội dung trao đổi, context càng đầy; một số lệnh (xem cheat sheet bên dưới) giúp dọn bớt context. |

### Cheat sheet: slash command hữu ích

Danh sách bên dưới là các lệnh phổ biến, thường gặp — vì hai CLI này cập nhật khá thường xuyên, hãy gõ `/help` ngay trong công cụ để xem danh sách đầy đủ và chính xác nhất tại thời điểm workshop diễn ra.

**Claude Code CLI (`claude`)**

| Lệnh | Công dụng |
|---|---|
| `/help` | Hiện danh sách lệnh đầy đủ |
| `/clear` | Xóa lịch sử hội thoại hiện tại, bắt đầu phiên mới sạch |
| `/compact` | Nén bớt lịch sử hội thoại dài để tiết kiệm context, vẫn giữ ý chính |
| `/model` | Đổi model đang dùng |
| `/init` | Tạo/khởi tạo file `CLAUDE.md` — nơi ghi hướng dẫn riêng cho một project |
| `/agents` | Xem/quản lý các subagent |
| `/permissions` | Xem hoặc chỉnh quyền hạn công cụ được phép tự chạy không cần hỏi |
| `/mcp` | Xem/quản lý các kết nối MCP server |
| `/resume` | Tiếp tục một phiên làm việc trước đó |
| `/cost` | Xem chi phí/mức sử dụng của phiên hiện tại |
| `/doctor` | Kiểm tra nhanh xem cấu hình/cài đặt có vấn đề gì không |
| `Esc` hoặc `Ctrl+C` | Dừng một lệnh/tác vụ đang chạy |

**Codex CLI (`codex`)**

| Lệnh | Công dụng |
|---|---|
| `/help` | Hiện danh sách lệnh đầy đủ |
| `/model` | Đổi model đang dùng |
| `/diff` | Xem các thay đổi (file đã sửa) trong phiên hiện tại |
| `/clear` | Xóa lịch sử phiên hiện tại |
| `/approvals` | Đổi chế độ phê duyệt hành động (tự động chạy vs. hỏi trước mỗi bước) |

*Ghi chú cho người hướng dẫn: nên tự kiểm tra lại danh sách này bằng `/help` trong bản `claude`/`codex` đang cài trên devcontainer trước ngày diễn ra, vì hai CLI này thay đổi khá nhanh giữa các phiên bản.*

## Phần 1 — Nền tảng (20 phút) — giữ nguyên như Bước 1–2 hiện tại

- Đọc chung `sql-helper/SKILL.md`, đi qua 3 bước lập luận của nó (chọn đúng database → nắm vững schema tương ứng → viết/chạy SQL).
- Cả nhóm cùng đặt một câu hỏi bằng ngôn ngữ tự nhiên, quan sát SQL được sinh ra, hiển thị, và chạy trực tiếp.
- Điểm mấu chốt cần nhấn mạnh: một Skill chỉ là hướng dẫn viết bằng chữ, không phải code — đây chính là mô hình tư duy được tái sử dụng ở Phần 3 và 4.

## Phần 2 — Thực hành Skill 1: Text-to-SQL (75 phút) — giữ nguyên như Bước 3–6 hiện tại

- Làm bộ câu hỏi phân cấp của Bài tập 1 — Bank Transaction Schema trong `WORKSHOP_EXERCISES.md` (Cơ bản → Trung cấp → Nâng cao).
- Copy `templates/skill-template/SKILL.md`, điền 3–5 quy tắc riêng, mirror sang `.codex/skills/`.
- Thử lại một câu hỏi mỗi cấp độ để thấy quy tắc riêng thay đổi hành vi của skill ("aha moment" của buổi sáng).
- 2–3 bạn tình nguyện demo nhanh để kết thúc phần này.

## Phần 3 — Skill 0: "Dạy agent tự đọc hiểu một database chưa từng thấy" (40 phút, mới)

**Đặt vấn đề với người tham gia:** `sql-helper` chạy tốt vì đã có người viết sẵn `schemas/BANK_DATASET_SCHEMA.md`. Dữ liệu thực tế thường không có tài liệu như vậy — đây chính là điểm nghẽn #1. Thử thách: xây một skill mà khi trỏ vào một file DuckDB chưa từng thấy, tự khám phá và viết ra một tài liệu schema đáng tin cậy.

- **Dữ liệu mục tiêu:** `data/custom.duckdb` của chính mỗi người (đã build từ `my-data/*.csv` qua `participants/local_setup/load_custom_data.sh` ở phần setup trước đó) — hoặc một file CSV "bí ẩn" do người hướng dẫn chuẩn bị sẵn cho ai chưa mang dữ liệu riêng.
- **Đề bài phát ra** (chỉ là checklist ngắn, không phải template đầy đủ — đúng tinh thần "tự tạo skill và bài tập của riêng mình"):
  - chạy `.tables`, `DESCRIBE` từng bảng, xem thử vài dòng dữ liệu mẫu
  - suy đoán ý nghĩa các cột chưa rõ ràng, nhưng phải nêu rõ mức độ không chắc chắn thay vì đoán bừa rồi im lặng
  - viết kết quả theo đúng định dạng bảng như trong `schemas/BANK_DATASET_SCHEMA.md`, để về lý thuyết có thể bỏ thẳng vào `schemas/` và dùng theo cách `sql-helper` đang dùng các file schema
- **Không có đáp án mẫu** — cố tình để mở, tiếp nối tinh thần "tự khám phá schema" của track dữ liệu tùy chỉnh hiện có, nhưng tự động hóa nó thành một skill dùng lại được thay vì làm thủ công một lần.
- **Thảo luận cuối phần:** Skill đoán sai hoặc đánh dấu không chắc ở đâu? Làm sao kiểm chứng lại? Gợi mở cho Phần 5: tài liệu schema vừa tạo ra có thể đưa thẳng vào một skill truy vấn.

## Phần 4 — Skill 2: "Biến kết quả truy vấn thành thứ người quản lý đọc được" (35 phút, mới)

**Đặt vấn đề với người tham gia:** Chạy 10 câu truy vấn không trả lời được "vậy thì nên làm gì" — đây là điểm nghẽn #3. Thử thách: xây một skill nhận vào một loạt câu hỏi đã có câu trả lời và tổng hợp thành một báo cáo insight ngắn, viết bằng chữ.

- **Đầu vào:** dùng lại 3–5 câu hỏi đã trả lời ở Phần 2 (hoặc đặt câu hỏi mới trên bộ dữ liệu tech-salary cho đa dạng).
- **Đề bài phát ra** (2–3 câu, không có template): skill cần chạy lại/tái sử dụng N câu truy vấn, sau đó tổng hợp thành một đoạn tường thuật ngắn — một con số chủ đạo, 2–3 phát hiện hỗ trợ, một giả định/lưu ý rõ ràng — viết cho người đọc không rành kỹ thuật.
- **Nguyên tắc bắt buộc kế thừa từ Skill 1:** kỷ luật "luôn hiển thị SQL đã dùng" cũng áp dụng ở đây — skill báo cáo phải chỉ rõ câu truy vấn nào đứng sau mỗi nhận định, không được khẳng định số liệu mà không có nguồn. Đây là quy tắc duy nhất nên nêu rõ thay vì để hoàn toàn mở, vì "insight" không có căn cứ là lỗi dễ gặp nhất.

## Phần 5 — *(tùy chọn, nếu còn thời gian)* Skill 4: Kết nối thành một chuỗi (15–20 phút, mới, có thể cắt)

- Ghép Skill 0 → Skill 1 → Skill 2 thành một chuỗi trên một bộ dữ liệu agent chưa từng thấy: tạo schema → trả lời một câu hỏi nghiệp vụ → tóm tắt thành báo cáo. Đây là phần "trang bị cho agent các skill để hiểu dữ liệu của bạn tốt hơn" — tổng kết toàn bộ buổi.
- Nếu nhóm không đủ thời gian cho việc kết nối đầy đủ, có thể dùng Bài tập 2 sẵn có (Bước 7 trong `WORKSHOP_EXERCISES.md`, mở rộng skill từ Phần 2 để định tuyến sang cả bộ dữ liệu tech-salary) làm phương án nhẹ hơn.
- Luôn nói rõ đây là phần tùy chọn: cắt đầu tiên nếu trễ giờ, hoặc giao làm bài tự học sau buổi, tham khảo `participants/ARCHITECTURE.md` để hiểu mô hình tư duy nền tảng (skill chỉ là hướng dẫn, không có runtime lưu trạng thái, mọi thứ kết nối qua tài liệu schema + lệnh CLI).

## Phần 6 — Demo & tổng kết (15–20 phút)

- 2–3 bạn tình nguyện trình bày tài liệu schema (Skill 0) và/hoặc báo cáo insight (Skill 2) của mình.
- Tổng kết lại chuỗi Hiểu → Truy vấn → Diễn giải → Kết nối, chỉ đến `participants/exercises_answer_key_bank_schema.ipynb`, `participants/exercises_answer_key_salary_schema.ipynb`, và `participants/ARCHITECTURE.md` để tự học thêm, thu thập phản hồi.

---

## Điều gì giữ nguyên, điều gì mới

- **Giữ nguyên:** nội dung Phần 0–2 (skill mẫu, bộ câu hỏi, tự xây skill, demo) — phần lõi đã được kiểm chứng, giữ y như Bước 1–6 trong `WORKSHOP_EXERCISES.md` hiện tại.
- **Mới:** Phần 3 và 4 (Skill 0 và Skill 2) trở thành bài tập chính thức trong buổi, thay vì chỉ là gợi ý làm sau workshop như hiện nay.
- **Mới, tùy chọn rõ ràng:** Phần 5 (Skill 4 — kết nối chuỗi), đặt ở vị trí tương tự bài mở rộng đa-dataset (Bước 7) hiện có — một mục tiêu vươn xa cho nhóm còn thời gian, không phải nội dung cốt lõi.
