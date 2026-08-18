---
name: TODO-ten-skill-cua-ban
description: TODO — một câu mô tả khi nào skill này nên được kích hoạt, ví dụ "Dùng skill này khi người dùng hỏi về <chủ đề> bằng ngôn ngữ tự nhiên."
---

# TODO: Tên Skill

TODO: Một hoặc hai câu về việc skill này giúp làm gì, cho dữ liệu nào.

## Khám phá schema trước

Đây là dữ liệu của riêng bạn — không có sẵn một file kiểu `schemas/BANK_DATASET_SCHEMA.md`
được viết trước cho nó. Trước khi viết bất kỳ câu SQL nào, hãy tự khám phá
schema và ghi lại hiểu biết đó ngay bên dưới:

```bash
duckdb data/custom.duckdb -c ".tables"
duckdb data/custom.duckdb -c "DESCRIBE ten_bang;"
duckdb data/custom.duckdb -c "SELECT * FROM ten_bang LIMIT 5;"
```

### Bảng & cột (TODO — điền vào sau khi khám phá)

TODO: với mỗi bảng, ghi tên bảng, các cột quan trọng, kiểu dữ liệu, và ý
nghĩa — giống hệt những gì `schemas/BANK_DATASET_SCHEMA.md` làm cho dữ liệu ngân
hàng, nhưng cho dữ liệu của bạn. Không bao giờ tự bịa ra tên bảng hoặc tên
cột không có trong kết quả bạn vừa khám phá ở trên.

## Chạy truy vấn

Luôn truy vấn cơ sở dữ liệu tại `data/custom.duckdb`, ví dụ:

```bash
duckdb data/custom.duckdb -c "SELECT ... "
```

## Quy tắc chung

Viết bên dưới 3–5 dòng chỉ dẫn thể hiện một quy tắc do bạn chọn. Một vài ví
dụ tham khảo (hãy thay bằng quy tắc của riêng bạn):

1. TODO — ví dụ "Luôn giải thích câu truy vấn bằng một câu ngôn ngữ tự nhiên trước khi hiển thị SQL."
2. TODO — ví dụ "Luôn làm tròn số về 2 chữ số thập phân."
3. TODO — ví dụ "Luôn sắp xếp kết quả theo ngày giảm dần trừ khi được yêu cầu khác."
4. TODO (tùy chọn)
5. TODO (tùy chọn)

## Lưu ý

Dữ liệu này chỉ đến từ file CSV trong `my-data/`. Nếu bạn thêm/sửa/xóa file
trong đó và chạy lại `./participants/local_setup/load_custom_data.sh`, schema có thể thay đổi (bảng
đổi tên do trùng tên, cột đổi kiểu do dữ liệu mới) — hãy chạy lại bước khám
phá schema ở trên và cập nhật phần "Bảng & cột" cho khớp.
