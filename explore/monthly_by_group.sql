-- Quick look: online units per week, by month and group.
-- Uses the weekly average because some months have 4 weeks and others 5.
SELECT
    DATE_TRUNC('month', week_start) AS month,
    ROUND(SUM(units) / COUNT(DISTINCT week_start)) AS total_wk,
    ROUND(SUM(CASE WHEN index_group = 'Ladieswear'    THEN units END) / COUNT(DISTINCT week_start)) AS ladies_wk,
    ROUND(SUM(CASE WHEN index_group = 'Divided'       THEN units END) / COUNT(DISTINCT week_start)) AS divided_wk,
    ROUND(SUM(CASE WHEN index_group = 'Menswear'      THEN units END) / COUNT(DISTINCT week_start)) AS mens_wk,
    ROUND(SUM(CASE WHEN index_group = 'Sport'         THEN units END) / COUNT(DISTINCT week_start)) AS sport_wk,
    ROUND(SUM(CASE WHEN index_group = 'Baby/Children' THEN units END) / COUNT(DISTINCT week_start)) AS kids_wk
FROM mart.weekly_sales
WHERE channel = 'online'
GROUP BY month
ORDER BY month
