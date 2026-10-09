-- Q2. Which product groups sell the most online?
SELECT
    -- 1 = group that sells the most
    RANK() OVER (ORDER BY SUM(units) DESC) AS sales_rank,
    index_group,
    SUM(units) AS units,

    -- total of all groups online, needed for the %
    ROUND(100.0 * SUM(units) / SUM(SUM(units)) OVER (), 1)     AS units_pct,
    ROUND(100.0 * SUM(revenue) / SUM(SUM(revenue)) OVER (), 1) AS revenue_pct,

    -- average price per item, to compare groups
    ROUND(SUM(revenue) / SUM(units), 4) AS avg_price
FROM mart.weekly_sales
WHERE channel = 'online'
GROUP BY index_group
ORDER BY sales_rank

-- Result: Ladieswear (64.1%) and Divided (24.4%) make up 88.5% of online units.
-- The other three groups are under 5% each.
-- Ladieswear has the highest avg price (0.0311), Baby/Children the lowest (0.0203).
-- Baby/Children has the second largest catalog but only 3.3% of online units.
