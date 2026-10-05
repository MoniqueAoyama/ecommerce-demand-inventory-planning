"""Convert the Kaggle CSV files to Parquet and load them into DuckDB (raw layer).

Run once from the project root:
    python src/01_load_raw.py
"""
from pathlib import Path

import duckdb

RAW = Path("data/raw")
PARQUET = Path("data/parquet")
DB_PATH = "data/hm.duckdb"

# article_id has leading zeros, so it must be read as text.
# customers.csv has no article_id column, so it needs no option.
TABLES = {
    "articles": "types={'article_id': 'VARCHAR'}",
    "customers": "",
    "transactions_train": "types={'article_id': 'VARCHAR'}",
}


def main():
    PARQUET.mkdir(parents=True, exist_ok=True)
    con = duckdb.connect(DB_PATH)
    con.execute("CREATE SCHEMA IF NOT EXISTS raw")

    for name, options in TABLES.items():
        csv_path = RAW / f"{name}.csv"
        parquet_path = PARQUET / f"{name}.parquet"

        if options:
            reader = f"read_csv('{csv_path}', {options})"
        else:
            reader = f"read_csv('{csv_path}')"

        # 1. CSV -> Parquet (smaller and much faster to query)
        con.execute(f"COPY (SELECT * FROM {reader}) TO '{parquet_path}' (FORMAT PARQUET)")

        # 2. Parquet -> table in the raw schema
        con.execute(
            f"CREATE OR REPLACE TABLE raw.{name} AS SELECT * FROM read_parquet('{parquet_path}')"
        )

        rows = con.execute(f"SELECT COUNT(*) FROM raw.{name}").fetchone()[0]
        print(f"raw.{name}: {rows:,} rows")

    con.close()


if __name__ == "__main__":
    main()
