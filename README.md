# E-commerce Demand & Inventory Planning

Demand planning project built on real transaction data from H&M's Kaggle
competition (31.8M purchases, Sep 2018 to Sep 2020).

The project works through the questions a planning team faces every week:
how much each product group is expected to sell, how much inventory is
needed to cover that demand, and what actions make sense for the business.

Work in progress, built in phases.

## Data

Source: [H&M Personalized Fashion Recommendations](https://www.kaggle.com/competitions/h-and-m-personalized-fashion-recommendations/data)

| Table | Rows | Description |
| --- | --- | --- |
| transactions | 31.8M | purchase date, customer, article, price, sales channel |
| articles | 105K | product attributes and hierarchy |
| customers | 1.37M | customer attributes |

The analysis focuses on online sales, with store sales used for comparison.
Since the dataset has no inventory information, inventory levels are
simulated from the forecasts.

## Database

The files are loaded into a DuckDB database with three layers.

| Layer | Tables | Content |
| --- | --- | --- |
| raw | transactions_train, articles, customers | Kaggle files, unchanged |
| clean | transactions, articles | clearer column names, sales channel as text |
| mart | weekly_sales | units and revenue by week, channel and index group |

The weekly table covers 104 full weeks. The first and last weeks of the
dataset are incomplete, so they were left out.

## Findings so far

- Online is the main channel, with 70.4% of all transactions.
- The dataset does not say which channel code is online. Channel 1 has no
  sales in April 2020, which matches the store closures, so channel 1 is
  stores and channel 2 is online.
- Online has sales in all 104 weeks for every index group. Stores have a
  gap of five to six weeks in spring 2020.

## Plan

- [x] Load the Kaggle files into DuckDB
- [x] Clean layer and weekly sales table
- [ ] Business questions in SQL
- [ ] Weekly demand forecast for the online channel in R
- [ ] Safety stock and reorder points
- [ ] Tableau dashboard

## Later

- Machine learning models for the forecast, compared with the simpler ones
- Forecast by product type
- Monthly S&OP report

## How to run

Download the three CSV files from Kaggle into `data/raw/`, then:

    python -m venv .venv
    source .venv/bin/activate
    pip install duckdb
    python src/01_load_raw.py
    python src/run_sql.py sql/02_clean/01_transactions.sql
    python src/run_sql.py sql/02_clean/02_articles.sql
    python src/run_sql.py sql/04_marts/01_weekly_sales.sql

## Tools

Python, SQL, DuckDB

## Contact

Monique Aoyama · [LinkedIn](https://www.linkedin.com/in/moniqueaoyama/)
