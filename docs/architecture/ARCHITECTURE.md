# Kiến Trúc Hệ Thống

Tài liệu này dành cho các kỹ sư (techies) muốn hiểu cách repo này vận hành ở mức hệ thống — không phải hướng dẫn từng bước để chạy workshop (xem `../setup/`) hay checklist vận hành (xem `../reference/`). Nó mô tả các thành phần, luồng dữ liệu, và các quyết định thiết kế đứng sau chúng.

## Tóm tắt

Repo này **không phải là một ứng dụng** — không có build step, không có test suite, không có server chạy liên tục. Nó là:

1. Một **cơ sở dữ liệu DuckDB đã đóng gói sẵn** (`data/workshop.duckdb`, ~5.87 triệu dòng / 10 bảng, phân phối qua Git LFS).
2. Một **môi trường devcontainer** tái tạo được (Codespaces hoặc Docker cục bộ) cài sẵn DuckDB CLI, Claude Code CLI, và Codex CLI.
3. Một **cặp Skill mẫu** (`.claude/skills/sql-helper/`, mirror sang `.codex/skills/sql-helper/`) hướng dẫn model chuyển câu hỏi ngôn ngữ tự nhiên thành SQL, dựa trên `BANK_DATASET_SCHEMA.md` làm nguồn sự thật duy nhất về dữ liệu.
4. Bộ tài liệu Markdown làm "chất keo" — dữ liệu thô + hướng dẫn agent + tài liệu hướng dẫn con người, không có tầng logic ứng dụng nào ở giữa.

Nói cách khác: **model chính là runtime**. Không có backend, không có API, không có ORM — CLI của Claude Code / Codex đọc `SKILL.md`, tự viết SQL, và shell ra `duckdb` CLI để chạy nó trực tiếp trên file `.duckdb` cục bộ.

## Hai pipeline: build-time và run-time

Có một ranh giới rõ ràng giữa việc *chuẩn bị* dữ liệu (làm một lần, bởi ban tổ chức) và việc *dùng* dữ liệu (làm lại mỗi lần, bởi mỗi người tham gia / mỗi Codespace).

```mermaid
flowchart TB
    subgraph build["BUILD-TIME — ban tổ chức, chạy một lần, ngoài container"]
        csv["dataset/*.csv\n(CSV gốc từ Kaggle, git-ignored)"]
        script["Python + gói duckdb\nCREATE TABLE ... AS SELECT * FROM read_csv_auto"]
        db["data/workshop.duckdb\n(~75MB, theo dõi qua Git LFS)"]
        csv --> script --> db
    end

    subgraph distribute["PHÂN PHỐI"]
        lfs["Git LFS\n(pointer file trong Git, blob thật lưu ở LFS storage)"]
        db -->|"git lfs push / commit"| lfs
    end

    subgraph runtime["RUN-TIME — mỗi người tham gia, container riêng, tái tạo mỗi lần"]
        checkout["repo checkout + git lfs pull"]
        container["Devcontainer\n(Codespaces hoặc Docker cục bộ)"]
        skills[".claude/skills/sql-helper/\n.codex/skills/sql-helper/"]
        schema["BANK_DATASET_SCHEMA.md\n(từ điển dữ liệu)"]
        clis["claude CLI  /  codex CLI"]
        duckcli["duckdb CLI"]

        lfs -->|"tải blob thật"| checkout --> container
        container --> clis
        clis -->|"đọc hướng dẫn"| skills
        skills -->|"tự neo (ground) vào"| schema
        clis -->|"sinh SQL, chạy qua"| duckcli
        duckcli -->|"truy vấn"| db
    end

    user(["Người tham gia\nđặt câu hỏi ngôn ngữ tự nhiên"]) --> clis
    duckcli -->|"kết quả dạng bảng"| user
```

**Vì sao tách ra như vậy:**
- Build-time chỉ chạy **một lần** vì dữ liệu tĩnh — không có ingest pipeline sống, không có cron job cập nhật dữ liệu.
- Run-time phải **tái tạo được hoàn toàn từ đầu** với chi phí thấp, vì nó chạy 20–50 lần song song (mỗi người tham gia một Codespace) trong nửa ngày.
- Container không bao giờ tự dựng lại `data/workshop.duckdb` — nó chỉ đọc file đã build sẵn. Điều này giữ cho `postCreateCommand` nhanh (vài chục giây, không phải vài phút) và loại bỏ khả năng mỗi Codespace nạp dữ liệu khác nhau.

## Vòng đời một câu truy vấn

Đây là những gì thực sự xảy ra khi một người tham gia gõ một câu hỏi ngôn ngữ tự nhiên vào `claude` hoặc `codex`:

```mermaid
sequenceDiagram
    participant U as Người dùng
    participant CLI as claude / codex CLI
    participant SK as SKILL.md
    participant SC as BANK_DATASET_SCHEMA.md
    participant DB as duckdb CLI → workshop.duckdb

    U->>CLI: Câu hỏi ngôn ngữ tự nhiên\n("5 danh mục merchant có tổng amount cao nhất?")
    CLI->>SK: Câu hỏi khớp trigger phrase trong frontmatter description → kích hoạt skill
    SK->>SC: Yêu cầu model đọc BANK_DATASET_SCHEMA.md trước khi viết SQL
    SC-->>CLI: Tên bảng/cột/kiểu dữ liệu/giá trị hợp lệ
    CLI->>CLI: Sinh câu lệnh SQL (tuân theo quy tắc trong SKILL.md:\nLIMIT 100, làm tròn tiền tệ, ưu tiên GROUP BY...)
    CLI->>DB: Shell out: duckdb data/workshop.duckdb -c "SELECT ..."
    DB-->>CLI: Kết quả dạng bảng
    CLI-->>U: Hiển thị câu SQL đã chạy + kết quả + giải thích ngắn
```

**Điểm mấu chốt về mặt kiến trúc:** `claude`/`codex` **không** có kết nối trực tiếp, có trạng thái (stateful connection) tới DuckDB. Mỗi truy vấn là một lời gọi CLI độc lập, không giữ session — không có connection pooling, không có transaction xuyên nhiều lượt hỏi. Điều này giữ cho mô hình bảo mật đơn giản (không có gì để rò rỉ ngoài chính file `.duckdb`) nhưng cũng có nghĩa là **mọi ràng buộc về tính đúng đắn của SQL sinh ra đều nằm ở tầng prompt** (`SKILL.md`), không có tầng validate ở giữa.

## Bản đồ thành phần

```mermaid
flowchart LR
    subgraph repo["Nội dung repo (Git)"]
        direction TB
        cfg[".devcontainer/devcontainer.json\nkhai báo image + features + hooks"]
        pc[".devcontainer/postCreate.sh\ncài đặt, chạy 1 lần khi container được tạo"]
        pa[".devcontainer/postAttach.sh\nin banner chào mừng, chạy mỗi lần attach"]
        shim[".devcontainer/duckdb_shim.py\nfallback CLI cho môi trường musl/Alpine"]
        setupsh["setup.sh\nphiên bản cục bộ của postCreate.sh,\ndùng khi không chạy trong devcontainer"]
        schema["BANK_DATASET_SCHEMA.md\ntừ điển dữ liệu — nguồn sự thật duy nhất"]
        skillA[".claude/skills/sql-helper/SKILL.md\nfile thật"]
        skillB[".codex/skills/sql-helper/SKILL.md\nsymlink → bản .claude"]
        tmpl["templates/skill-template/SKILL.md\nkhung trống cho bài tập tự xây skill"]
        exdoc["exercises.md\ncâu hỏi mẫu để luyện tập"]
        docsSetup["docs/setup/\nkế hoạch + hướng dẫn thiết lập (ban tổ chức)"]
        docsRef["docs/reference/\nchecklist ngày diễn ra + xử lý sự cố (facilitator)"]
    end

    subgraph runtime_env["Container lúc chạy"]
        direction TB
        base["mcr.microsoft.com/devcontainers/base:ubuntu\n+ Node feature + git-lfs feature"]
        installed["duckdb CLI · claude CLI · codex CLI\n(cài bởi postCreate.sh)"]
    end

    subgraph data_layer["Tầng dữ liệu"]
        direction TB
        duckdb_file["data/workshop.duckdb\n(Git LFS)"]
    end

    cfg -->|"postCreateCommand"| pc
    cfg -->|"postAttachCommand"| pa
    pc -->|"cài lên"| base --> installed
    pc -->|"musl fallback dùng"| shim
    pc -->|"chạy smoke test trên"| duckdb_file
    installed -->|"đọc"| skillA
    skillA -.->|"symlink"| skillB
    skillA -->|"tham chiếu"| schema
    skillA -->|"truy vấn"| duckdb_file
    tmpl -.->|"copy làm khung cho skill mới"| skillA
```

## Hai đường chạy container: Codespaces và cục bộ

`devcontainer.json` là nguồn cấu hình **duy nhất** cho cả hai đường chạy — không có config riêng cho local. Sự khác biệt chỉ nằm ở nơi Docker Engine chạy và cách OAuth redirect hoạt động.

| | GitHub Codespaces | Devcontainer cục bộ |
|---|---|---|
| Docker Engine | Do GitHub host | Docker Desktop / Engine trên máy bạn |
| Kích hoạt | `codespaces.new/...` hoặc nút "Open in Codespaces" | `devcontainer up --workspace-folder .` (CLI `@devcontainers/cli`) |
| `postCreateCommand` / `postAttachCommand` | Giống hệt | Giống hệt |
| Git LFS pull | Tự động qua GitHub token có sẵn | `git lfs pull` cần credentials cục bộ |
| OAuth redirect (đăng nhập `claude`/`codex`) | Qua port forwarding của Codespaces | Qua `localhost` trực tiếp |
| Dùng để | Trải nghiệm thật của người tham gia | Chạy thử của ban tổ chức trước ngày diễn ra (xem `../setup/Iteration_0_LocalTesting.md`) |

`setup.sh` (ở gốc repo) là một đường thứ ba — dùng khi ai đó muốn chạy workshop **ngoài** devcontainer hoàn toàn (máy cá nhân, không Docker). Nó lặp lại đúng các bước của `postCreate.sh` (cài DuckDB/Claude/Codex CLI, `git lfs pull`, smoke test) nhưng chạy trực tiếp trên máy host thay vì trong container, và có thêm các bước kiểm tra prerequisite (`git`, `curl`, `node`) mà devcontainer đã đảm bảo sẵn qua base image.

## Các quyết định thiết kế đáng chú ý

- **Phân phối dữ liệu qua Git LFS, không qua ingest pipeline sống.** Dataset tĩnh (bản chụp một lần từ Kaggle), nên build một lần rồi ship binary `.duckdb` là đơn giản hơn nhiều so với để mỗi container tự chạy lại `read_csv_auto` trên ~6 triệu dòng CSV lúc khởi động.
- **`BANK_DATASET_SCHEMA.md` là nguồn sự thật duy nhất, không phải introspection runtime.** Skill được hướng dẫn đọc file Markdown tĩnh thay vì tự chạy `DESCRIBE`/`PRAGMA` để khám phá schema — giữ cho hành vi model có thể dự đoán được và cho phép ban tổ chức kiểm soát chính xác những gì model "biết" về dữ liệu (bao gồm cả các ghi chú/điểm đặc biệt trong phần "Lưu ý & điểm đặc biệt").
- **`.codex/skills/sql-helper/SKILL.md` là symlink, không phải bản copy.** Đảm bảo Claude Code và Codex CLI luôn nhận đúng cùng một bộ hướng dẫn — sửa một nơi (`.claude/`), cả hai CLI cùng cập nhật. Rủi ro đánh đổi: symlink không luôn được các công cụ Windows/zip xử lý đúng, nên `postCreate.sh`/tài liệu setup có bước xác minh cho việc này.
- **Fallback musl/Alpine cho DuckDB CLI (`duckdb_shim.py`).** Binary CLI chính thức của DuckDB liên kết với glibc và không chạy trên musl. Thay vì yêu cầu mọi môi trường phải là glibc, `postCreate.sh` phát hiện Alpine và cài gói Python `duckdb` (có sẵn musllinux wheel) đứng sau một shim script mô phỏng interface CLI (`duckdb <db> -c "<SQL>"`, `-csv`, `-json`, `-noheader`, stdin). Bất kỳ thay đổi nào về cách workshop gọi CLI `duckdb` đều phải giữ tương thích với tập flag mà shim này hỗ trợ.
- **Không có tầng validate SQL giữa model và DuckDB.** Model shell trực tiếp ra `duckdb` CLI với câu SQL nó tự sinh — không có allowlist câu lệnh, không có read-only enforcement ở tầng ứng dụng. An toàn dữ liệu dựa vào: (a) dataset là bản sao tổng hợp/không nhạy cảm, (b) mỗi người tham gia chỉ có quyền trên container/file của chính họ, và (c) các quy tắc trong `SKILL.md` (ví dụ ưu tiên `SELECT`/tổng hợp) là hướng dẫn hành vi cho model, không phải rào chắn kỹ thuật.
- **Container tách biệt hoàn toàn khỏi `dataset/*.csv`.** File CSV gốc bị git-ignore và không tồn tại trong container lúc chạy — chỉ `data/workshop.duckdb` (đã build sẵn) mới quan trọng ở run-time. Điều này giữ cho kích thước container nhỏ và loại bỏ phụ thuộc vào toolchain build (Python + `duckdb` package) ở phía người tham gia.

## Bản đồ tài liệu liên quan

- `../setup/WORKSHOP_SETUP_PLAN.md` — vì sao các quyết định thiết kế ở trên được đưa ra, dưới góc nhìn tổ chức workshop.
- `../setup/WORKSHOP_SETUP_GUIDE_LOCAL.md`, `../setup/WORKSHOP_SETUP_GUIDE_CODESPACES.md` — checklist xác minh dry-run cho hai đường chạy container.
- `../setup/Iteration_0_LocalTesting.md` — kiểm thử toàn bộ luồng run-time cục bộ trước khi mời người tham gia.
- `../reference/DAY_OF_CHECKLIST.md`, `../reference/FACILITATOR_TROUBLESHOOTING.md` — vận hành thực tế trong ngày diễn ra.
- `../../BANK_DATASET_SCHEMA.md` — từ điển dữ liệu đầy đủ (10 bảng).
- `../../CLAUDE.md` — hướng dẫn dành cho Claude Code khi làm việc trong repo này (tiếng Anh, không dịch).
