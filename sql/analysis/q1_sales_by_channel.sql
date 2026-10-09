-- Q1. Which channel sells more, online or store?
SELECT
    channel,
    SUM(units) AS units,

    -- Total of both channels, needed for the %
    ROUND(100.0 * SUM(units) / SUM(SUM(units)) OVER (), 1)     AS units_pct,
    ROUND(100.0 * SUM(revenue) / SUM(SUM(revenue)) OVER (), 1) AS revenue_pct,

    -- Average price per item. Prices are normalized, so only compare channels
    ROUND(SUM(revenue) / SUM(units), 4) AS avg_price
FROM mart.weekly_sales
GROUP BY channel
ORDER BY units DESC

-- Result: online has 70.4% of units but 75.6% of revenue.
-- Avg price is 0.0299 online vs 0.0229 in stores, about 30% higher online.
-- Not clear why from this data. Could be pricier items online or more
-- discounts in stores. Comparing the same articles in both channels
-- would answer it.
