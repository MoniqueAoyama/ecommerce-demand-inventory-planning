-- Weekly sales by channel and index group.
-- One row per week, channel and index group.
-- This is the table the forecast and the dashboard read from.
--
-- The first and last weeks are left out because they are incomplete
-- (4 and 2 days of sales, see sql/analysis/01_partial_weeks.sql).
CREATE SCHEMA IF NOT EXISTS mart;

CREATE OR REPLACE TABLE mart.weekly_sales AS
SELECT
    CAST(DATE_TRUNC('week', t.sale_date) AS DATE) AS week_start,
    t.channel,
    a.index_group,
    COUNT(*)     AS units,
    SUM(t.price) AS revenue
FROM clean.transactions AS t
JOIN clean.articles AS a
    ON t.article_id = a.article_id
WHERE t.sale_date >= DATE '2018-09-24'
  AND t.sale_date <  DATE '2020-09-21'
GROUP BY week_start, t.channel, a.index_group;

-- Quick check: number of weeks and total units
SELECT
    COUNT(*)                   AS row_count,
    COUNT(DISTINCT week_start) AS weeks,
    MIN(week_start)            AS first_week,
    MAX(week_start)            AS last_week,
    SUM(units)                 AS total_units
FROM mart.weekly_sales
