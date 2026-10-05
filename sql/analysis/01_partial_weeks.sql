-- How many days of sales does each week have?
-- A full week has 7 days. This lists the weeks that have fewer.
SELECT
    DATE_TRUNC('week', sale_date) AS week_start,
    COUNT(DISTINCT sale_date)     AS days_with_sales,
    COUNT(*)                      AS transactions
FROM clean.transactions
GROUP BY week_start
HAVING COUNT(DISTINCT sale_date) < 7
ORDER BY week_start
