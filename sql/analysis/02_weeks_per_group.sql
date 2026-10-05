-- How many weeks of sales does each channel and index group have?
-- A full combination has 104 weeks. Fewer than that means weeks with no sales.
SELECT
    channel,
    index_group,
    COUNT(*) AS weeks
FROM mart.weekly_sales
GROUP BY channel, index_group
ORDER BY weeks, channel, index_group

-- Result: online has all 104 weeks in every index group.
-- Store is missing 5 or 6 weeks per group (28 rows in total).
-- This matches the period with no store sales found in 00_data_checks.sql.
