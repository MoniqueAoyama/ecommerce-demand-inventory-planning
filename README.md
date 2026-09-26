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

## Plan

- [ ] Phase 1: DuckDB database (raw, clean, star schema, marts)
- [ ] Phase 2: sales trends, seasonality and demand disruptions
- [ ] Phase 3: weekly demand forecasting and model comparison
- [ ] Phase 4: safety stock and reorder points
- [ ] Phase 5: Power BI dashboard and monthly S&OP report

## Tools

Python, SQL, DuckDB, pandas, matplotlib

## Contact

Monique Aoyama · [LinkedIn](https://www.linkedin.com/in/moniqueaoyama/)
