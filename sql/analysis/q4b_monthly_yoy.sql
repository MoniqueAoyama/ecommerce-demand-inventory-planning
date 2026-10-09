-- Q4b. Did the online drop start before the pandemic?
-- Compares each month with the same month one year earlier.
WITH monthly AS (
    SELECT
        DATE_TRUNC('month', week_start) AS month,
        COUNT(DISTINCT week_start) AS weeks,

        -- weekly average, since some months have 4 weeks and others 5
        SUM(units) / COUNT(DISTINCT week_start) AS units_wk
    FROM mart.weekly_sales
    WHERE channel = 'online'
    GROUP BY month
),
compared AS (
    SELECT
        month,
        weeks,
        units_wk,

        -- same month last year = 12 rows back (no months are missing)
        LAG(weeks, 12)    OVER (ORDER BY month) AS weeks_ly,
        LAG(units_wk, 12) OVER (ORDER BY month) AS units_wk_ly
    FROM monthly
)
SELECT
    strftime(month, '%Y-%m') AS month,
    ROUND(units_wk)::INTEGER    AS units_wk,
    ROUND(units_wk_ly)::INTEGER AS last_year_wk,
    ROUND(100.0 * (units_wk - units_wk_ly) / units_wk_ly, 1) AS change_pct
FROM compared

-- only full months (4 or 5 weeks), so Sep 2018 and Sep 2020 are left out
WHERE weeks >= 4 AND weeks_ly >= 4
ORDER BY month

-- Result: every month from Oct 2019 to Feb 2020 sold less than a year
-- before (-4% to -21%), so the drop started before the pandemic.
-- Mar and Apr 2020 are the only months above last year (+5.3%, +19.3%).
