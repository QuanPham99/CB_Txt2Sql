#!/usr/bin/env bash
# Nạp dữ liệu CSV của riêng bạn vào DuckDB — một lệnh duy nhất.
# Chạy từ thư mục gốc repo:
#
#   ./load_custom_data.sh
#
# Đặt một hoặc nhiều file .csv vào thư mục my-data/, sau đó chạy lệnh trên.
# Script sẽ luôn XÂY LẠI data/custom.duckdb từ đầu — dữ liệu trong đó luôn
# khớp chính xác với những gì đang có trong my-data/ tại thời điểm chạy.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_ROOT"

INPUT_DIR="my-data"
OUT_DB="data/custom.duckdb"

bold() { printf '\033[1m%s\033[0m\n' "$1"; }
step() { printf '\n== %s ==\n' "$1"; }
ok()   { printf '  ok: %s\n' "$1"; }
warn() { printf '  cảnh báo: %s\n' "$1"; }
fail() { printf '\nLỖI: %s\n' "$1" >&2; exit 1; }

step "Kiểm tra điều kiện cần thiết"

command -v duckdb >/dev/null 2>&1 || fail "Không tìm thấy duckdb CLI. Hãy chạy ./setup.sh trước, hoặc cài đặt: curl https://install.duckdb.org | sh"
ok "duckdb đã sẵn sàng ($(duckdb --version))"

step "Kiểm tra thư mục ${INPUT_DIR}/"

mkdir -p "$INPUT_DIR"
shopt -s nullglob
csv_files=("$INPUT_DIR"/*.csv "$INPUT_DIR"/*.CSV)
other_files=("$INPUT_DIR"/*.xlsx "$INPUT_DIR"/*.XLSX "$INPUT_DIR"/*.xls "$INPUT_DIR"/*.XLS)

for f in "${other_files[@]}"; do
  warn "Bỏ qua '$f' — script này chỉ hỗ trợ file .csv. Excel được giới thiệu riêng qua Claude for Excel, không nằm trong repo này. Nếu cần, hãy xuất (export) file Excel thành .csv rồi thử lại."
done

if [ "${#csv_files[@]}" -eq 0 ]; then
  fail "Không tìm thấy file .csv nào trong ${INPUT_DIR}/. Hãy copy file CSV của bạn vào đó rồi chạy lại. Ví dụ: cp ~/Downloads/du_lieu.csv ${INPUT_DIR}/"
fi
ok "tìm thấy ${#csv_files[@]} file CSV"

step "Xây lại ${OUT_DB} từ đầu"

rm -f "$OUT_DB" "${OUT_DB}.wal"
mkdir -p "$(dirname "$OUT_DB")"

sanitize_name() {
  local name
  name=$(basename "$1")
  name="${name%.*}"
  name=$(printf '%s' "$name" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/_/g; s/^_+//; s/_+$//')
  if [[ "$name" =~ ^[0-9] ]] || [ -z "$name" ]; then
    name="t_${name}"
  fi
  printf '%s' "$name"
}

declare -A used_names=()
RESOLVED_NAME=""

# Sets RESOLVED_NAME instead of returning via stdout/command-substitution —
# `$(...)` forks a subshell in bash, which would silently discard the
# used_names[] update and defeat collision detection entirely.
resolve_collision() {
  local base="$1" candidate="$1" n=2
  while [ -n "${used_names[$candidate]+x}" ]; do
    candidate="${base}_${n}"
    n=$((n + 1))
  done
  used_names["$candidate"]=1
  RESOLVED_NAME="$candidate"
}

loaded=0
skipped=0

# Sắp xếp để thứ tự đặt hậu tố khi trùng tên luôn nhất quán giữa các lần chạy.
IFS=$'\n' sorted_csv_files=($(printf '%s\n' "${csv_files[@]}" | sort))
unset IFS

for csv in "${sorted_csv_files[@]}"; do
  base_name="$(sanitize_name "$csv")"
  resolve_collision "$base_name"
  tbl="$RESOLVED_NAME"
  if [ "$tbl" != "$base_name" ]; then
    warn "Trùng tên bảng '${base_name}' — '$csv' sẽ được đặt tên là \"${tbl}\"."
  fi

  sql="CREATE TABLE \"${tbl}\" AS SELECT * FROM read_csv('${csv//\'/\'\'}', header=true);"
  if ! duckdb "$OUT_DB" -c "$sql" >/dev/null 2>/tmp/load_custom_data_err.$$; then
    warn "Không thể nạp '$csv' — bỏ qua (kiểm tra định dạng/encoding). Chi tiết: $(cat /tmp/load_custom_data_err.$$ 2>/dev/null | tr '\n' ' ')"
    rm -f /tmp/load_custom_data_err.$$
    unset "used_names[$tbl]"
    skipped=$((skipped + 1))
    continue
  fi
  rm -f /tmp/load_custom_data_err.$$

  # DuckDB có thể tự "sniff" lại một file có số cột không đồng nhất thay vì
  # báo lỗi. Đối chiếu số dòng đã nạp với số dòng thực tế trong file để bắt
  # được trường hợp này (giả định file không có xuống dòng bên trong ô có
  # dấu ngoặc kép — đúng với CSV thông thường của workshop).
  file_lines=$(awk 'END{print NR}' "$csv")
  expected_rows=$((file_lines - 1))
  actual_rows=$(duckdb "$OUT_DB" -csv -noheader -c "SELECT count(*) FROM \"${tbl}\";")
  if [ "$actual_rows" -ne "$expected_rows" ]; then
    warn "'$csv' có vẻ không đúng định dạng (số cột không đồng nhất giữa các dòng) — bỏ qua bảng \"${tbl}\"."
    duckdb "$OUT_DB" -c "DROP TABLE \"${tbl}\";" >/dev/null
    unset "used_names[$tbl]"
    skipped=$((skipped + 1))
    continue
  fi

  ok "$csv -> bảng \"${tbl}\" (${actual_rows} dòng)"
  loaded=$((loaded + 1))
done

if [ "$loaded" -eq 0 ]; then
  rm -f "$OUT_DB" "${OUT_DB}.wal"
  fail "Không nạp được bảng nào — xem các cảnh báo ở trên."
fi

duckdb "$OUT_DB" -c "CHECKPOINT;" >/dev/null

step "Tóm tắt"

duckdb "$OUT_DB" -csv -noheader -c "SELECT table_name FROM information_schema.tables ORDER BY table_name;" | while IFS= read -r tbl; do
  [ -z "$tbl" ] && continue
  cnt=$(duckdb "$OUT_DB" -csv -noheader -c "SELECT count(*) FROM \"${tbl}\";")
  printf '  %-30s %s dòng\n' "$tbl" "$cnt"
done

SIZE="$(du -h "$OUT_DB" | cut -f1)"
echo "Đã nạp ${loaded} bảng vào ${OUT_DB} (${SIZE}), bỏ qua ${skipped} file."

cat <<BANNER

========================================================
 Xong! Bước tiếp theo:

 1. Khám phá dữ liệu của bạn:
      duckdb ${OUT_DB} -c ".tables"
      duckdb ${OUT_DB} -c "DESCRIBE <tên_bảng>;"

 2. Copy khung skill mẫu:
      templates/custom-data-skill-template/SKILL.md
    vào .claude/skills/<tên-của-bạn>/SKILL.md (và mirror sang
    .codex/skills/<tên-của-bạn>/), rồi điền những gì bạn vừa
    khám phá ở bước 1 vào đó.

 3. Mỗi lần bạn thêm/sửa/xóa file trong ${INPUT_DIR}/, chạy lại
    script này để xây lại ${OUT_DB} từ đầu.
========================================================
BANNER
