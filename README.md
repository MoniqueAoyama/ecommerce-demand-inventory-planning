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
dataset are incomplete, so they were left out. The table is also exported
to [exports/weekly_sales.csv](exports/weekly_sales.csv) for R and Tableau.

## Data checks

- The dataset does not say which channel code is online. Channel 1 has no
  sales in April 2020, which matches the store closures, so channel 1 is
  stores and channel 2 is online.
- Online has sales in all 104 weeks for every index group. Stores have a
  gap of five to six weeks in spring 2020.

## Business questions

| | Question | Answer |
| --- | --- | --- |
| [Q1](sql/analysis/q1_sales_by_channel.sql) | Which channel sells more? | Online has 70% of units and 76% of revenue. The average online item costs about 30% more than in stores. |
| [Q2](sql/analysis/q2_top_index_groups.sql) | Which groups sell the most online? | Ladieswear and Divided together are 88.5% of online units. The other three groups are under 5% each. |
| [Q3](sql/analysis/q3_weekly_trend.sql) | What were the peak weeks online? | Black Friday, mid-June in both years, and April 2020 when stores were closed. |
| [Q4](sql/analysis/q4_year_over_year.sql) | How much did each group grow from year 1 to year 2? | Online fell 7.8%. Only Sport grew. Baby/Children fell 64%. |
| [Q4b](sql/analysis/q4b_monthly_yoy.sql) | Did the drop start before the pandemic? | Yes. Every month from Oct 2019 to Feb 2020 sold less than a year before. Only Mar and Apr 2020 were above. |
| [Q5](sql/analysis/q5_moving_average.sql) | How stable is weekly demand? | A typical week lands 15% to 19% away from its 4-week average, similar across groups. |

Also explored:

- [Channel mix](explore/groups_by_channel.sql): Divided sells relatively
  more online, while Menswear and Baby/Children sell relatively more in
  stores. Stock for one channel shouldn't copy the other.
- [Monthly sales by group](explore/monthly_by_group.sql): Baby/Children
  dropped from about 20,000 to 7,000 units a week between Oct 2018 and
  Mar 2019, and stayed low. Not related to the pandemic.

## What this means for the forecast

- The June and Black Friday peaks repeat every year, so the models need
  yearly seasonality. Two years of data give only two examples of each.
- April 2020 is a one-off spike from the store closures, not normal demand.
- Baby/Children moved to a much lower level in early 2019, so its older
  weeks don't describe current demand.

## Plan

- [x] Load the Kaggle files into DuckDB
- [x] Clean layer and weekly sales table
- [x] Business questions in SQL
- [x] Export the weekly table to CSV
- [ ] Weekly demand forecast for the online channel in R
- [ ] Safety stock and reorder points
- [ ] Tableau dashboard

## Later

- Machine learning models for the forecast, compared with the simpler ones
- Forecast by product type
- Compare prices of the same articles online and in stores
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
    python src/run_sql.py sql/05_export/01_weekly_sales.sql

Any file in `sql/analysis/` runs the same way.

## Tools

Python, SQL, DuckDB

## Contact

Monique Aoyama · [LinkedIn](https://www.linkedin.com/in/moniqueaoyama/)
