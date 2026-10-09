-- Quick look: share of each group in each channel
SELECT
    channel,
    index_group,
    SUM(units) AS units,

    -- PARTITION BY channel makes the % add up to 100 inside each channel
    ROUND(100.0 * SUM(units) / SUM(SUM(units)) OVER (PARTITION BY channel), 1) AS units_pct
FROM mart.weekly_sales
GROUP BY channel, index_group
ORDER BY channel, units DESC

-- Result: Ladieswear is about 64% in both channels.
-- Divided is stronger online (24.4% vs 17.9%), Menswear is stronger
-- in stores (8.5% vs 4.4%), and so is Baby/Children (5.0% vs 3.3%).
