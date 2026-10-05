-- Clean version of the transactions table.
-- Same rows as raw, with clearer column names and the channel as text.
-- 1 = store, 2 = online (checked in sql/analysis/00_data_checks.sql)
CREATE SCHEMA IF NOT EXISTS clean;

CREATE OR REPLACE TABLE clean.transactions AS
SELECT
    t_dat        AS sale_date,
    customer_id,
    article_id,
    price,
    CASE sales_channel_id
        WHEN 1 THEN 'store'
        WHEN 2 THEN 'online'
    END          AS channel
FROM raw.transactions_train;

-- Quick check: the counts should match the raw table
SELECT channel, COUNT(*) AS transactions
FROM clean.transactions
GROUP BY channel
ORDER BY channel
