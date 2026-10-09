-- Q3. What were the peak weeks for online sales?
SELECT
    week_start,
    SUM(units) AS units,

    -- How much above an average week, in %
    ROUND(100.0 * SUM(units) / AVG(SUM(units)) OVER () - 100, 1) AS vs_avg_pct
FROM mart.weekly_sales
WHERE channel = 'online'
GROUP BY week_start
ORDER BY units DESC
LIMIT 10


-- Result: an average online week sells about 213,500 units.
-- Peaks come from Black Friday (Nov 2018 and Nov 2019), mid-June in
-- both years (likely the summer sale) and April 2020, when stores
-- were closed and shoppers moved online.
-- The June peak repeats every year, so the forecast needs to account for it.
