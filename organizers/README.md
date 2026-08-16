# Tài Nguyên Dành Cho Ban Tổ Chức

Kế hoạch thiết lập, các hướng dẫn dry-run, và tài liệu vận hành cho người tổ chức/chạy workshop này. Không dành cho người tham gia — xem [`../participants/README.md`](../participants/README.md) nếu bạn đang tìm tài liệu cho người tham gia.

| File | Mục đích |
|---|---|
| [`WORKSHOP_SETUP_PLAN.md`](WORKSHOP_SETUP_PLAN.md) | Tài liệu nền — bối cảnh và lý do cho mọi quyết định thiết lập bên dưới. Đọc file này trước tiên. |
| [`WORKSHOP_SETUP_GUIDE_CODESPACES.md`](WORKSHOP_SETUP_GUIDE_CODESPACES.md) | Checklist dry-run: chạy thử toàn bộ workshop trên một GitHub Codespace thật trước khi mời người tham gia. |
| [`WORKSHOP_SETUP_GUIDE_LOCAL.md`](WORKSHOP_SETUP_GUIDE_LOCAL.md) | Checklist dry-run: chạy thử toàn bộ workshop trên máy cá nhân, không cần GitHub/Codespaces. |
| [`Iteration_0_LocalTesting.md`](Iteration_0_LocalTesting.md) | Kiểm thử cục bộ tương đương container thật, qua Docker + devcontainer CLI — bước kiểm thử sớm nhất trước cả hai dry-run ở trên. |
| [`DAY_OF_CHECKLIST.md`](DAY_OF_CHECKLIST.md) | Checklist hậu cần trước workshop và ngày diễn ra. |
| [`FACILITATOR_TROUBLESHOOTING.md`](FACILITATOR_TROUBLESHOOTING.md) | Xử lý sự cố trực tiếp trong buổi (mở sẵn trên màn hình thứ hai khi chạy workshop). |
| [`build_tech_salary_db.sh`](build_tech_salary_db.sh) | Script dựng lại `data/tech_salary.duckdb` từ CSV thô trong `tech_salary_dataset/` (git-ignored). |

## Thứ tự đề xuất khi chuẩn bị một workshop

1. `WORKSHOP_SETUP_PLAN.md` — hiểu bối cảnh và các quyết định đã có.
2. `Iteration_0_LocalTesting.md` — kiểm thử container cục bộ qua Docker.
3. `WORKSHOP_SETUP_GUIDE_LOCAL.md` — dry-run đầy đủ trên máy cá nhân.
4. `WORKSHOP_SETUP_GUIDE_CODESPACES.md` — dry-run đầy đủ trên Codespaces thật.
5. `DAY_OF_CHECKLIST.md` — hậu cần trước và trong ngày diễn ra.

Là người tham gia workshop? Bạn không cần thư mục này — xem [`../README.md`](../README.md) và [`../participants/README.md`](../participants/README.md) thay vào đó.
