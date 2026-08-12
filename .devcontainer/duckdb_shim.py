#!/usr/bin/env python3
# Fallback `duckdb` CLI for musl-based containers, where the official glibc-linked
# DuckDB CLI binary can't execute even under gcompat (missing symbols like
# __res_init). Backs onto the `duckdb` Python package instead, which ships
# musllinux wheels. Supports the subset of CLI usage this workshop relies on:
#   duckdb <database> -c "<SQL>"
#   duckdb <database> -csv -noheader -c "<SQL>"
#   duckdb <database>              (reads ;-terminated statements from stdin)
import csv
import json
import sys

import duckdb


def main():
    args = sys.argv[1:]
    db_path = None
    sql = None
    fmt = "table"
    header = True

    i = 0
    while i < len(args):
        arg = args[i]
        if arg == "-c":
            i += 1
            sql = args[i]
        elif arg == "-csv":
            fmt = "csv"
        elif arg == "-json":
            fmt = "json"
        elif arg == "-noheader":
            header = False
        elif not arg.startswith("-"):
            db_path = arg
        i += 1

    if db_path is None:
        print("usage: duckdb <database> [-csv] [-json] [-noheader] [-c SQL]", file=sys.stderr)
        sys.exit(1)

    con = duckdb.connect(db_path)

    def emit(cols, rows):
        if fmt == "json":
            print(json.dumps([dict(zip(cols, row)) for row in rows], default=str))
        elif fmt == "csv":
            writer = csv.writer(sys.stdout)
            if header and cols:
                writer.writerow(cols)
            writer.writerows(rows)
        else:
            if header and cols:
                print(" | ".join(cols))
            for row in rows:
                print(" | ".join(str(v) for v in row))

    def run(stmt):
        stmt = stmt.strip()
        if not stmt:
            return
        try:
            result = con.execute(stmt)
        except Exception as exc:
            print(f"Error: {exc}", file=sys.stderr)
            sys.exit(1)
        cols = [d[0] for d in result.description] if result.description else []
        rows = result.fetchall() if cols else []
        emit(cols, rows)

    if sql is not None:
        run(sql)
        return

    buf = ""
    for line in sys.stdin:
        buf += line
        if buf.strip().endswith(";"):
            run(buf)
            buf = ""
    if buf.strip():
        run(buf)


if __name__ == "__main__":
    main()
