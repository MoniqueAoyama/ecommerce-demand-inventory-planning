-- Q4. How much did each group grow from the first year to the second? (online)
WITH yearly AS (
    SELECT
        index_group,

        -- the 104 weeks split into two years of 52 weeks
        SUM(CASE WHEN week_start <  DATE '2019-09-23' THEN units END) AS units_y1,
        SUM(CASE WHEN week_start >= DATE '2019-09-23' THEN units END) AS units_y2
    FROM mart.weekly_sales
    WHERE channel = 'online'
    GROUP BY index_group
)
SELECT
    index_group,
    units_y1,
    units_y2,
    ROUND(100.0 * (units_y2 - units_y1) / units_y1, 1) AS growth_pct
FROM yearly
ORDER BY growth_pct DESC


-- Result: online fell 7.8% from year 1 to year 2 (11.55M to 10.66M units),
-- even with the April 2020 jump. Only Sport grew (+7.8%).
-- Baby/Children dropped 64%, far more than any other group.
-- Not clear why from this data, could be a business change or how the
-- Kaggle dataset was sampled.