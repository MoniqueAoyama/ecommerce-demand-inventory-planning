"""Run a SQL file against the project database and print each result.

Usage:
    python src/run_sql.py sql/analysis/00_data_checks.sql
"""
import sys
from pathlib import Path

import duckdb

DB_PATH = "data/hm.duckdb"


def main():
    sql_file = Path(sys.argv[1])
    con = duckdb.connect(DB_PATH)

    # Run each statement in the file and show its result
    for statement in sql_file.read_text().split(";"):
        if statement.strip():
            result = con.sql(statement)
            if result is not None:
                result.show(max_rows=60)

    con.close()


if __name__ == "__main__":
    main()
