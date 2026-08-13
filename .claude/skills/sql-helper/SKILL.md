---
name: sql-helper
description: Truy vấn dữ liệu giao dịch ngân hàng — dùng skill này bất cứ khi nào người dùng đặt câu hỏi bằng ngôn ngữ tự nhiên về accounts, transactions, cards, loans, customers, branches, employees, hoặc support tickets. Các cụm từ kích hoạt bao gồm "có bao nhiêu...", "tổng số... là bao nhiêu", "khách hàng/tài khoản/chi nhánh nào...", "text to SQL", "truy vấn dữ liệu".
---

# SQL Helper

Bạn trả lời các câu hỏi bằng ngôn ngữ tự nhiên về bộ dữ liệu ngân hàng của workshop bằng cách viết và chạy SQL trên một file DuckDB cục bộ.

## Nắm vững dữ liệu trước

Trước khi viết bất kỳ câu SQL nào, hãy đọc `BANK_DATASET_SCHEMA.md` ở thư mục gốc của repo. Đây là nguồn thông tin duy nhất và chính xác cho tên bảng, tên cột, kiểu dữ liệu, và các giá trị hợp lệ (ví dụ `txn_type`, `merchant_category`, `status`). Không bao giờ tự bịa ra tên cột hoặc tên bảng không có trong đó — nếu câu hỏi cần dữ liệu không có trong schema, hãy nói rõ điều đó thay vì đoán mò.

## Chạy truy vấn

Luôn truy vấn cơ sở dữ liệu tại `data/workshop.duckdb`, ví dụ:

```bash
duckdb data/workshop.duckdb -c "SELECT ... "
```

## Quy tắc chung

1. **Luôn hiển thị câu SQL đã chạy** trước khi hiển thị kết quả, để người dùng có thể học theo.
2. **Luôn dùng `LIMIT 100`** với bất kỳ truy vấn nào trả về dữ liệu thô theo dòng, trừ khi người dùng yêu cầu rõ nhiều hơn hoặc truy vấn đã là dạng tổng hợp chỉ trả về vài dòng.
3. **Không bao giờ tự bịa tên cột hoặc tên bảng** — nếu không chắc chắn, hãy kiểm tra lại `BANK_DATASET_SCHEMA.md` thay vì đoán.
4. **Ưu tiên tổng hợp thay vì liệt kê thô** — nếu câu hỏi có thể trả lời bằng `COUNT`, `SUM`, hoặc `GROUP BY`, hãy làm vậy thay vì trả về hàng trăm dòng dữ liệu thô.
5. **Nêu rõ các giả định** — ví dụ nếu "tháng trước" không rõ ràng do khoảng thời gian của dữ liệu, hãy nói rõ bạn đã dùng mốc ngày nào (xem phần "Lưu ý & điểm đặc biệt" trong `BANK_DATASET_SCHEMA.md`).
6. **Làm tròn tiền tệ về 2 chữ số thập phân** trong câu trả lời cuối cùng, ngay cả khi cột dữ liệu gốc có độ chính xác cao hơn.

## Ví dụ

Người dùng hỏi: *"5 danh mục merchant có tổng số tiền giao dịch cao nhất là gì?"*

```sql
SELECT merchant_category, ROUND(SUM(amount), 2) AS total_amount
FROM transactions
GROUP BY merchant_category
ORDER BY total_amount DESC
LIMIT 5;
```

Sau đó giải thích kết quả trong một hoặc hai câu.
