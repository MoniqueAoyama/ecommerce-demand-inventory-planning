-- Q5. How stable is weekly demand online, by group?
WITH smoothed AS (
    SELECT
        index_group,
        week_start,
        units,

        -- 4-week moving average: this week and the 3 before
        AVG(units) OVER (
            PARTITION BY index_group
            ORDER BY week_start
            ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
        ) AS ma_4wk
    FROM mart.weekly_sales
    WHERE channel = 'online'
)
SELECT
    index_group,
    ROUND(AVG(units))::INTEGER AS avg_units_wk,

    -- std dev as a % of the average, so big and small groups can be compared
    ROUND(100.0 * STDDEV(units) / AVG(units), 1) AS cv_pct,

    -- how far a week usually lands from its 4-week moving average
    ROUND(100.0 * AVG(ABS(units - ma_4wk) / ma_4wk), 1) AS vs_ma_pct
FROM smoothed
GROUP BY index_group
ORDER BY cv_pct DESC

-- Result: week to week, every group lands about 15% to 19% away from
-- its 4-week moving average, smaller groups a bit more.
-- Baby/Children's cv is 80.5% because sales dropped a lot in early 2019,
-- not because they jump around week to week. Week to week (vs_ma_pct 19.2%)
-- it behaves like the other groups.