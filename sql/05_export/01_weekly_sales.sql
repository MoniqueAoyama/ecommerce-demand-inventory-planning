-- Export the weekly sales table to CSV for R and Tableau.
-- Small file (about 1,000 rows), so it goes in the repo.
COPY (
    SELECT *
    FROM mart.weekly_sales
    ORDER BY week_start, channel, index_group
) TO 'exports/weekly_sales.csv' (HEADER, DELIMITER ',');

-- Quick check: read the file back
SELECT COUNT(*) AS row_count
FROM read_csv('exports/weekly_sales.csv')
