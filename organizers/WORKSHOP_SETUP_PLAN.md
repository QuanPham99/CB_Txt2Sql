# Workshop Kỹ Năng Text-to-SQL — Kế Hoạch Thiết Lập

## Bối cảnh

Mục tiêu là một workshop nửa ngày (20–50 người tham gia, kết hợp cả người có kỹ thuật lẫn không, một track thống nhất duy nhất) nơi mọi người học cách xây dựng một **Claude Skill / Codex Skill** để chuyển câu hỏi bằng ngôn ngữ tự nhiên thành SQL chạy trên DuckDB, sử dụng bộ dữ liệu Kaggle "Banking Transactions" làm sân chơi chung. Rào cản thiết lập là kẻ thù — đặc biệt với người tham gia không có kỹ thuật — nên toàn bộ môi trường (DuckDB + dữ liệu + Claude Code + Codex CLI + các extension VS Code) được đóng gói sẵn trong một devcontainer GitHub Codespaces, mở lên là dùng được ngay chỉ với một cú click.

Theo câu trả lời của bạn: người tham gia xác thực bằng tài khoản Claude / ChatGPT **của riêng họ** (không cần quản lý API key dùng chung), và bạn muốn **cơ sở dữ liệu cùng một bản mô tả schema bằng ngôn ngữ tự nhiên được chuẩn bị đầy đủ trước bởi bạn**, để người tham gia (và AI của họ) không bao giờ phải tự khám phá dữ liệu thô — họ chỉ cần đọc một từ điển dữ liệu ngắn gọn rồi bắt đầu đặt câu hỏi.

Lưu ý: tôi không thể lấy nội dung trang Kaggle thực tế từ môi trường này (mạng bị chặn tới kaggle.com), nên không thể điền sẵn tên cột thật ở đây. Phần 0 bên dưới được viết để bạn tự làm bước kiểm tra đó một lần, dùng chính DuckDB — vừa nhanh vừa là bước kiểm tra sơ bộ đầu tiên xem dữ liệu có nạp sạch hay không.

---

## Phần 0 — Ban tổ chức: Chuẩn bị dữ liệu (làm phần này trước tiên, trước khi dựng repo)

1. Tải file CSV từ https://www.kaggle.com/datasets/vivekmali1436/banking-transactions-dataset (nút "Download" trên web Kaggle, hoặc `kaggle datasets download -d vivekmali1436/banking-transactions-dataset` nếu bạn đã cài `kaggle` CLI + API token).
2. Kiểm tra dữ liệu cục bộ bằng DuckDB (cài DuckDB CLI trước — `curl https://install.duckdb.org | sh` trên Mac/Linux, hoặc `winget install DuckDB.cli` trên Windows) để nắm được schema thật trước khi ai khác chạm vào:
   ```sql
   duckdb
   CREATE TABLE transactions AS SELECT * FROM read_csv_auto('transactions.csv');
   DESCRIBE transactions;
   SUMMARIZE transactions;
   SELECT * FROM transactions LIMIT 20;
   ```
3. Quyết định tên bảng cuối cùng và, nếu cần, làm sạch/đổi tên cột sao cho thân thiện với workshop (snake_case, không viết tắt mơ hồ). Lưu dữ liệu đã làm sạch thành DB sẽ được đóng gói:
   ```sql
   COPY transactions TO 'workshop.duckdb'; -- hoặc cứ tiếp tục xây dựng trực tiếp trong một file .duckdb
   ```
4. Viết một **từ điển dữ liệu** ngắn gọn (đây là tài liệu mà người tham gia và AI thực sự sẽ đọc — giữ dưới ~40 dòng):
   - Tên bảng, số dòng, khoảng thời gian dữ liệu bao phủ
   - Mỗi cột: tên, kiểu dữ liệu, ý nghĩa một dòng, giá trị ví dụ
   - Bất kỳ điểm đặc biệt nào đã biết (giá trị null, đơn vị tiền tệ, các trường trông giống PII mà bạn đã ẩn danh/loại bỏ)
5. Lưu tài liệu này thành `schemas/BANK_DATASET_SCHEMA.md` ở thư mục gốc của repo — đây sẽ trở thành nguồn thông tin duy nhất và chính xác mà cả facilitator lẫn các mô hình AI dựa vào để trả lời.

---

## Phần 0b — Ban tổ chức: Chuẩn bị bộ dữ liệu Tech Salary (tùy chọn, độc lập với Phần 0)

Đây là một database DuckDB **thứ hai**, hoàn toàn độc lập với `data/workshop.duckdb`
— dùng cho bài tập mở rộng tùy chọn ở Phần 6 bên dưới, không thay thế dữ liệu
ngân hàng.

1. Tải file CSV từ https://www.kaggle.com/datasets/yaaryiitturan/global-tech-salary-dataset
   (nút "Download" trên Kaggle — file có thể ở dạng `.zip`, không sao, bước 3 tự
   giải nén).
2. Đặt file (CSV hoặc `.zip` như tải về) vào thư mục `tech_salary_dataset/` ở
   gốc repo (thư mục này bị git bỏ qua, giống `dataset/`).
3. Chạy:
   ```bash
   ./organizers/build_tech_salary_db.sh
   ```
   Script tự nhận diện mọi file CSV trong `tech_salary_dataset/` (tự giải nén
   `.zip` nếu cần), tạo một bảng cho mỗi CSV trong `data/tech_salary.duckdb`,
   và dừng lại kèm thông báo lỗi rõ ràng nếu có file nào không đúng định dạng
   — không bao giờ để lại một database dở dang.
4. Kiểm tra dữ liệu vừa nạp:
   ```bash
   duckdb data/tech_salary.duckdb
   .tables
   DESCRIBE <tên_bảng>;
   SUMMARIZE <tên_bảng>;
   SELECT * FROM <tên_bảng> LIMIT 20;
   ```
5. Viết `schemas/TECH_SALARY_DATASET_SCHEMA.md` ở thư mục gốc repo, cùng định dạng
   với `schemas/BANK_DATASET_SCHEMA.md` (tên bảng/cột/kiểu dữ liệu/ý nghĩa/ví dụ +
   phần "Lưu ý & điểm đặc biệt"). Gợi ý: mở một phiên Claude Code ngay trong
   repo này và nhờ nó đọc `data/tech_salary.duckdb` rồi cùng bạn soạn tài
   liệu — đúng quy trình đã dùng để viết `schemas/BANK_DATASET_SCHEMA.md` ban đầu.
6. Điền câu hỏi ví dụ cụ thể vào Bước 7 của `WORKSHOP_EXERCISES.md` (hiện đang là
   TODO, vì tên bảng/cột thật chưa xác định được cho tới khi bạn tải file ở
   bước 1), và các cell tương ứng trong
   `../participants/exercises_answer_key_salary_schema.ipynb` (notebook này
   dành cho người tham gia tự đối chiếu kết quả, không còn là tài liệu
   facilitator-only).
7. Commit cả `data/tech_salary.duckdb` (đã được theo dõi qua Git LFS bởi
   pattern `data/*.duckdb` có sẵn trong `.gitattributes` — không cần chỉnh
   gì thêm) và `schemas/TECH_SALARY_DATASET_SCHEMA.md`.

---

## Phần 1 — Ban tổ chức: Thiết lập Repo & Codespaces

1. Tạo một repo GitHub mới (ví dụ `text2sql-skills-workshop`) — public hoặc nội bộ tổ chức, tùy vào việc người tham gia có thể truy cập được gì.
2. Thêm file `workshop.duckdb` đã chuẩn bị (đã nạp sẵn dữ liệu) vào repo, ví dụ tại `data/workshop.duckdb`. Nếu vượt quá ~50MB, dùng Git LFS (`git lfs track "*.duckdb"`) — kiểm tra dung lượng file thực tế sau Phần 0; các file CSV Kaggle loại này thường chỉ vài MB đến vài chục MB, nên có thể không cần LFS, nhưng vẫn nên xác nhận lại.
3. Tạo `.devcontainer/devcontainer.json`:
   - Base image: `mcr.microsoft.com/devcontainers/base:ubuntu`
   - `features`: feature Node.js (cần thiết để `npm install -g` Claude Code)
   - Script `postCreateCommand` thực hiện:
     - Cài DuckDB CLI (`curl https://install.duckdb.org | sh`)
     - Cài Claude Code: `npm install -g @anthropic-ai/claude-code`
     - Cài Codex CLI: `curl -fsSL https://chatgpt.com/codex/install.sh | sh`
     - Xác nhận `data/workshop.duckdb` tồn tại và chạy nhanh `SELECT count(*)` như một smoke test, in ra creation log của Codespace
   - `customizations.vscode.extensions`: `anthropic.claude-code`, extension VS Code chính thức của OpenAI Codex, và một extension DuckDB/SQL để duyệt bảng trong sidebar
   - `postAttachCommand` (tùy chọn): in ra một thông báo "welcome" ngắn trỏ tới `schemas/BANK_DATASET_SCHEMA.md` và tài liệu bài tập
4. Bật **Codespaces prebuilds** cho nhánh mặc định của repo một hoặc hai ngày trước workshop, để cả 20–50 người tham gia đều nhận được container ấm (đã dựng sẵn) thay vì phải cold-build mất vài phút trong lúc diễn ra. Đặt vùng (region) prebuild khớp với nơi đa số người tham gia đang ở.
5. Đặt **giới hạn chi tiêu Codespaces** ở cấp tổ chức (hoặc cấp repo) phù hợp với 20–50 người × nửa ngày sử dụng, và xác nhận Codespaces đã được bật cho mọi loại tài khoản người tham gia (tài khoản GitHub cá nhân hoạt động tốt sẵn; tài khoản công ty/doanh nghiệp có thể cần admin tổ chức bật Codespaces — nhắc điều này trong thông báo trước workshop).
6. Vì người tham gia dùng tài khoản Claude/ChatGPT của riêng mình, hãy thêm một ghi chú ngắn trong README về những gì họ cần chuẩn bị *trước* workshop: một tài khoản Claude.ai với gói đang hoạt động (hoặc Anthropic API key cá nhân) và một tài khoản ChatGPT có quyền truy cập Codex (Plus/Pro/Business/Edu, hoặc OpenAI API key cá nhân) — xem Phần 4.

---

## Phần 2 — Ban tổ chức: Tài liệu workshop trong repo

1. `README.md` — badge "Open in GitHub Codespaces" một cú click, chương trình, và liên kết tới `schemas/BANK_DATASET_SCHEMA.md`.
2. `schemas/BANK_DATASET_SCHEMA.md` — từ Phần 0.
3. Một skill ví dụ mẫu, được commit sẵn để người tham gia đọc trước khi tự viết skill của mình. Vì Codex CLI (2026) giờ đã đọc **cùng định dạng `SKILL.md`** như Claude Code, hãy viết một lần và tham chiếu từ cả hai thư mục công cụ:
   - `.claude/skills/sql-helper/SKILL.md` — file thật
   - `.codex/skills/sql-helper/SKILL.md` — symlink (hoặc bản sao) trỏ tới cùng nội dung
   - Nội dung: frontmatter với mô tả kích hoạt ("query the transactions data", "text to SQL"), chỉ dẫn luôn truy vấn qua DuckDB trên `data/workshop.duckdb`, dựa vào `schemas/BANK_DATASET_SCHEMA.md`, và tuân theo các quy tắc chung bạn chọn dạy (ví dụ luôn `LIMIT 100` trừ khi được yêu cầu khác, luôn hiển thị SQL đã chạy, không bao giờ bịa tên cột không có trong `schemas/BANK_DATASET_SCHEMA.md`).
4. `WORKSHOP_EXERCISES.md` — luồng bài tập hướng dẫn người tham gia làm theo trực tiếp (xem Phần 5), cộng thêm 5–8 câu hỏi ví dụ bằng ngôn ngữ tự nhiên với độ khó tăng dần (ví dụ: "tháng trước có bao nhiêu giao dịch" → "tài khoản nào có tổng số tiền chuyển đi cao nhất, phân theo tháng").
5. `templates/skill-template/SKILL.md` — một khung mẫu trống với frontmatter placeholder và các phần chỉ dẫn `TODO` cho bài tập "tự xây dựng skill".
6. Một tài liệu **xử lý sự cố dành cho facilitator** dài một trang (không nằm trong README dành cho người tham gia) bao gồm: Codespace bị kẹt lúc dựng → rebuild container; vòng lặp đăng nhập OAuth → thử flow device-code / kiểm tra SSO tổ chức; file DuckDB bị thiếu → chạy lại thủ công postCreateCommand; gặp rate limit → chuyển sang màn hình demo dùng chung.

---

## Phần 3 — Ban tổ chức: Chạy thử (dry run) & hậu cần ngày diễn ra

1. Vài ngày trước: tạo một Codespace mới từ repo giống hệt cách một người tham gia sẽ làm (đừng dùng lại Codespace dev của bạn), đo thời gian toàn bộ luồng từ đầu đến cuối (khởi động container → đăng nhập → câu truy vấn đầu tiên thành công), và sửa bất cứ điều gì chậm hoặc gây khó hiểu.
2. Xác nhận cả hai CLI xác thực suôn sẻ bằng tài khoản cá nhân/thử nghiệm theo flow OAuth mô tả ở Phần 4, trên cả trình duyệt Mac và Windows nếu có thể (người dùng WSL/Windows đôi khi gặp hành vi redirect OAuth khác nhau).
3. Chuẩn bị phương án dự phòng: một đoạn ghi màn hình 2 phút của luồng "vàng" (golden path), phòng khi demo trực tiếp hoặc mạng của ai đó bị lỗi.
4. Gửi email/Slack trước workshop cho người tham gia: liên kết repo, checklist "trước khi tham gia" (đã có tài khoản GitHub, tài khoản Claude.ai/ChatGPT với gói đang hoạt động, trình duyệt đã đăng nhập cả hai), và thời gian dự kiến để dựng Codespace.
5. Ngày diễn ra: giãn cách các lượt click "Open in Codespaces" một hoặc hai phút trên toàn phòng/cuộc gọi nếu có thể (50 lượt cold-start đồng thời có thể vẫn bị xếp hàng dù đã prebuild) — cách đơn giản là để chương trình tự nhiên tách "mọi người mở Codespace ngay bây giờ" khỏi "mọi người đăng nhập ngay bây giờ" cách nhau vài phút.

---

## Phần 4 — Người tham gia: Thiết lập (ngày diễn ra, các bước tối thiểu)

1. Có tài khoản GitHub, đã đăng nhập, trên trình duyệt.
2. Mở liên kết repo do ban tổ chức chia sẻ → click **Code → Codespaces → Create codespace on main** (hoặc badge một-cú-click trong README).
3. Đợi container dựng xong (sẽ nhanh — vì đã prebuild). VS Code mở ra trên trình duyệt (hoặc app desktop nếu họ chọn vậy).
4. Trong terminal tích hợp, xác thực từng công cụ một lần:
   - `claude` → làm theo URL được in ra, đăng nhập bằng tài khoản Claude.ai (Pro/Max) hoặc dán API key cá nhân nếu có.
   - `codex` → làm theo URL được in ra / click "Sign in with ChatGPT" trong icon sidebar của Codex, đăng nhập bằng tài khoản ChatGPT (Plus/Pro/Business/Edu) hoặc OpenAI API key cá nhân.
5. Kiểm tra sơ bộ dữ liệu đã có sẵn:
   ```sql
   duckdb data/workshop.duckdb
   SELECT * FROM transactions LIMIT 5;
   ```
6. Mở `schemas/BANK_DATASET_SCHEMA.md` và xem lướt qua — đó là toàn bộ phần "hiểu dữ liệu" cần thiết trước khi bắt đầu.

---

## Phần 5 — Người tham gia: Luồng workshop (do facilitator dẫn dắt)

1. **Cùng đọc**: mở ví dụ mẫu tại `.claude/skills/sql-helper/SKILL.md`, thảo luận skill là gì (chỉ dẫn + nền tảng dữ liệu mà AI đọc trước khi trả lời).
2. **Đặt câu hỏi bằng ngôn ngữ tự nhiên**: mọi người gõ một câu hỏi vào `claude` hoặc `codex` (ví dụ: "5 danh mục giao dịch có tổng số tiền cao nhất trong quý vừa rồi là gì?") và quan sát công cụ viết + chạy SQL trên `data/workshop.duckdb`, dùng skill ví dụ mẫu.
3. **Tự xây dựng skill của bạn**: sao chép `templates/skill-template/SKILL.md` vào một folder mới trong `.claude/skills/<tên-của-họ>/` (và nhân bản sang `.codex/skills/`), viết 3–5 dòng chỉ dẫn thể hiện một quy tắc do họ chọn (ví dụ: "luôn giải thích câu truy vấn bằng một câu," "luôn làm tròn tiền tệ về 2 chữ số thập phân," "luôn sắp xếp theo ngày giảm dần theo mặc định").
4. **Kiểm thử**: đặt lại câu hỏi cũ hoặc một câu hỏi mới bằng ngôn ngữ tự nhiên và xác nhận câu trả lời của AI giờ đã tuân theo quy tắc riêng của họ — đây là khoảnh khắc "à ha" dành cho người tham gia không có kỹ thuật (họ chỉ viết một đoạn văn mà đã thay đổi hành vi của AI, không cần viết code).
5. **Chia sẻ kết quả**: một vài tình nguyện viên trình bày skill của mình và demo câu hỏi/câu trả lời trực tiếp.

---

## Phần 6 (tùy chọn) — Bài tập mở rộng Tech Salary: vì sao lại thiết kế như vậy

- **Vẫn nửa ngày, không kéo dài.** Dữ liệu ngân hàng giữ nguyên độ sâu bài tập
  hiện tại (đây là lượt "học pattern"); Tech Salary chỉ là một lượt "wrap-up"
  ngắn — 2–3 câu hỏi, không phải một bộ bài tập đầy đủ thứ hai.
- **Một skill hợp nhất, không phải hai skill riêng.** Người tham gia mở rộng
  chính `SKILL.md` họ vừa xây ở Bước 4 để nó tự "ground" vào cả hai từ điển
  dữ liệu và tự chọn đúng database theo từng câu hỏi — thay vì copy sang một
  skill thứ hai. Đây là lựa chọn có cân nhắc: cách làm hai-skill-riêng đơn
  giản và an toàn hơn (không có rủi ro chọn nhầm database), nhưng một skill
  hợp nhất là phép thử trung thực hơn cho câu hỏi "skill này có thực sự khái
  quát hóa được không, hay chỉ đang lặp lại một schema đã thuộc." Kỹ thuật cụ
  thể (chạy hai lệnh `duckdb` riêng, hay dùng `ATTACH`) cố tình không được
  quy định trước trong bất kỳ tài liệu nào — để người tham gia tự quyết định.
- **Không có skill mẫu thứ hai do ban tổ chức cung cấp.** Chỉ có
  `schemas/TECH_SALARY_DATASET_SCHEMA.md` được chuẩn bị trước, giống `schemas/BANK_DATASET_SCHEMA.md`.
  Việc mở rộng skill là bài tập của người tham gia, không phải thứ họ copy từ
  một ví dụ mẫu thứ hai.
- **Không chấm điểm tự động.** Vẫn theo đúng pattern hiện tại: `WORKSHOP_EXERCISES.md`
  + notebook đáp án tham khảo (`../participants/exercises_answer_key_bank_schema.ipynb`,
  `../participants/exercises_answer_key_salary_schema.ipynb`), người tham gia
  tự đối chiếu bằng mắt.
- **"Insight Report dựa trên SQL" chỉ là gợi ý take-home**, không phải một
  skill/script/template nào được xây trong repo — mục tiêu chính của phần
  này là dạy cách xây skill và kiểm thử nó với tác vụ Text-to-SQL; bước tiếp
  theo (biến nhiều truy vấn thành một bản tóm tắt) là để người tham gia tự
  phát triển sau workshop.

## Phần 7 (tùy chọn) — Dữ liệu tùy chỉnh cục bộ: vì sao lại thiết kế như vậy

- **Chạy cục bộ, không phải Codespaces** — người tham gia clone repo về máy
  cá nhân. Xem `../participants/LOCAL_SETUP_GUIDE.md` (Phần A, Phần C) cho
  hướng dẫn từng bước.
- **Hướng dẫn thủ công + trợ lý kỹ thuật, không phải installer tự động.** Có
  một trợ lý kỹ thuật hỗ trợ trực tiếp người tham gia cài đặt, nên phần này
  ưu tiên một tài liệu rõ ràng, chính xác (để trợ lý đọc/làm cùng người tham
  gia) hơn là một script cài đặt tự động không người giám sát — bớt rủi ro
  và công sức bảo trì một installer đa nền tảng (Windows/macOS), đổi lại mỗi
  người cài cục bộ cần trợ lý hỗ trợ ít nhất ở những bước đầu.
- **Chỉ hỗ trợ CSV.** Hỗ trợ Excel bị loại khỏi phạm vi `participants/local_setup/load_custom_data.sh`
  một cách có chủ đích — có một sản phẩm riêng (Claude for Excel) đã xử lý
  tốt việc này, sẽ được giới thiệu như một phần trình bày/demo riêng, không
  cần xây lại trong repo workshop này.
- **Không có từ điển dữ liệu được tạo tự động.** Khác với `schemas/BANK_DATASET_SCHEMA.md`,
  người tham gia tự khám phá schema của chính dữ liệu họ (`.tables`,
  `DESCRIBE`) và tự viết vào `SKILL.md` của mình — đây là một phần cố ý của
  bài tập, không phải một tính năng còn thiếu.

---

## Xác minh

- Trước workshop: tạo một Codespace từ repo như một người tham gia mới, xác nhận DuckDB có dữ liệu (`SELECT count(*) FROM transactions`), cả `claude` và `codex` xác thực được qua OAuth, cả hai extension VS Code đều tải được, và skill ví dụ mẫu thay đổi rõ rệt hành vi của model khi thử với một câu hỏi mẫu.
- Đo thời gian từ lúc mở container nguội đến câu truy vấn đầu tiên, đảm bảo nó vừa vặn thoải mái trong phần mở đầu của chương trình nửa ngày.
