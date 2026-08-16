#!/usr/bin/env bash
# Organizer-only. Builds data/tech_salary.duckdb from raw CSV(s) dropped in
# tech_salary_dataset/. Always rebuilds from scratch — run again any time the
# raw CSV(s) change.
#
#   ./scripts/build_tech_salary_db.sh
#
# Source dataset: https://www.kaggle.com/datasets/yaaryiitturan/global-tech-salary-dataset
# Download it, drop the CSV(s) (or the Kaggle .zip as-is) into
# tech_salary_dataset/, then run this script.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

INPUT_DIR="tech_salary_dataset"
OUT_DB="data/tech_salary.duckdb"

bold() { printf '\033[1m%s\033[0m\n' "$1"; }
step() { printf '\n== %s ==\n' "$1"; }
ok()   { printf '  ok: %s\n' "$1"; }
warn() { printf '  warning: %s\n' "$1"; }
fail() { printf '\nERROR: %s\n' "$1" >&2; exit 1; }

command -v duckdb >/dev/null 2>&1 || fail "duckdb CLI not found on PATH. Run ./setup.sh first, or install: curl https://install.duckdb.org | sh"

step "Locating input CSV(s) in ${INPUT_DIR}/"
[ -d "$INPUT_DIR" ] || fail "${INPUT_DIR}/ doesn't exist. Download the dataset from https://www.kaggle.com/datasets/yaaryiitturan/global-tech-salary-dataset, place the CSV(s)/zip into ${INPUT_DIR}/, then re-run."

shopt -s nullglob
csv_files=("$INPUT_DIR"/*.csv "$INPUT_DIR"/*.CSV)
zip_files=("$INPUT_DIR"/*.zip "$INPUT_DIR"/*.ZIP)

if [ "${#csv_files[@]}" -eq 0 ] && [ "${#zip_files[@]}" -gt 0 ]; then
  warn "No .csv found directly, but found a .zip — extracting."
  command -v unzip >/dev/null 2>&1 || fail "unzip is required to extract the Kaggle .zip. Install it and re-run, or extract the .zip yourself into ${INPUT_DIR}/."
  for z in "${zip_files[@]}"; do
    unzip -o -q "$z" -d "$INPUT_DIR"
  done
  csv_files=("$INPUT_DIR"/*.csv "$INPUT_DIR"/*.CSV)
fi

[ "${#csv_files[@]}" -gt 0 ] || fail "No .csv files found in ${INPUT_DIR}/ (checked for a .zip to auto-extract too)."
ok "found ${#csv_files[@]} CSV file(s)"

step "Rebuilding ${OUT_DB} from scratch"
rm -f "$OUT_DB" "${OUT_DB}.wal"
mkdir -p "$(dirname "$OUT_DB")"

sanitize() {
  local name
  name=$(basename "$1")
  name="${name%.*}"
  name=$(printf '%s' "$name" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/_/g; s/^_+//; s/_+$//')
  if [[ "$name" =~ ^[0-9] ]] || [ -z "$name" ]; then
    name="t_${name}"
  fi
  printf '%s' "$name"
}

for csv in "${csv_files[@]}"; do
  tbl="$(sanitize "$csv")"
  sql="CREATE TABLE \"${tbl}\" AS SELECT * FROM read_csv_auto('${csv//\'/\'\'}', sample_size=-1);"
  if ! duckdb "$OUT_DB" -c "$sql"; then
    rm -f "$OUT_DB" "${OUT_DB}.wal"
    fail "Failed to build table \"${tbl}\" from ${csv} — see the DuckDB error above. ${OUT_DB} was removed (this script never leaves a partial database behind)."
  fi
  # DuckDB's CSV sniffer can silently reinterpret a ragged file (inconsistent
  # column counts) instead of erroring — it may pick the wrong row as header
  # and drop rows rather than fail loudly. Cross-check the loaded row count
  # against the file's own line count to catch that case. (Heuristic: assumes
  # no embedded newlines inside quoted fields, which is true for this
  # workshop's expected inputs.)
  file_lines=$(awk 'END{print NR}' "$csv")
  expected_rows=$((file_lines - 1))
  actual_rows=$(duckdb "$OUT_DB" -csv -noheader -c "SELECT count(*) FROM \"${tbl}\";")
  if [ "$actual_rows" -ne "$expected_rows" ]; then
    rm -f "$OUT_DB" "${OUT_DB}.wal"
    fail "${csv} looks malformed (ragged row widths) — expected ${expected_rows} data row(s) but DuckDB loaded ${actual_rows} into \"${tbl}\". Fix the CSV (consistent column count on every row) and re-run. ${OUT_DB} was removed."
  fi
done
duckdb "$OUT_DB" -c "CHECKPOINT;" >/dev/null

step "Row count summary"
TABLES=$(duckdb "$OUT_DB" -csv -noheader -c "SELECT table_name FROM information_schema.tables ORDER BY table_name;")
[ -n "$TABLES" ] || fail "Build finished but ${OUT_DB} has zero tables."
while IFS= read -r tbl; do
  [ -z "$tbl" ] && continue
  cnt=$(duckdb "$OUT_DB" -csv -noheader -c "SELECT count(*) FROM \"${tbl}\";")
  ok "${tbl}: ${cnt} rows"
done <<< "$TABLES"

cat <<'BANNER'

========================================================
 data/tech_salary.duckdb built. Next steps (organizer):

 1. Inspect it:
      duckdb data/tech_salary.duckdb
      .tables
      DESCRIBE <table>;
      SUMMARIZE <table>;
      SELECT * FROM <table> LIMIT 20;

 2. Hand-author TECH_SALARY_DATASET_SCHEMA.md at repo root,
    same format as BANK_DATASET_SCHEMA.md (table/column/type/
    meaning/example + a "Luu y & diem dac biet" section). Tip:
    open a Claude Code session in this repo and ask it to
    inspect data/tech_salary.duckdb and draft the doc with
    you — same process originally used for BANK_DATASET_SCHEMA.md.

 3. Fill in the real example questions in exercises.md's
    tech-salary wrap-up section, and the matching answer cells
    in docs/reference/exercises_answer_key.ipynb.

 4. Commit both data/tech_salary.duckdb (Git LFS — already
    covered by the existing .gitattributes data/*.duckdb rule)
    and TECH_SALARY_DATASET_SCHEMA.md.
========================================================
BANNER
