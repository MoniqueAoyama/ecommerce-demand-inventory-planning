-- Data checks on the raw layer

-- 1. Period covered and number of customers and articles with sales
SELECT
    MIN(t_dat)                  AS first_day,
    MAX(t_dat)                  AS last_day,
    COUNT(*)                    AS transactions,
    COUNT(DISTINCT customer_id) AS customers,
    COUNT(DISTINCT article_id)  AS articles
FROM raw.transactions_train;

-- 2. Share of transactions by sales channel
SELECT
    sales_channel_id,
    COUNT(*)                                           AS transactions,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct
FROM raw.transactions_train
GROUP BY sales_channel_id
ORDER BY sales_channel_id;

-- 3. Product hierarchy: how many articles in each index group
SELECT
    index_group_name,
    COUNT(*) AS articles
FROM raw.articles
GROUP BY index_group_name
ORDER BY articles DESC;

-- 4. Which channel is online? Stores closed in spring 2020,
--    so the store channel should collapse around April 2020.
SELECT
    date_trunc('month', t_dat)                             AS month,
    SUM(CASE WHEN sales_channel_id = 1 THEN 1 ELSE 0 END) AS channel_1,
    SUM(CASE WHEN sales_channel_id = 2 THEN 1 ELSE 0 END) AS channel_2
FROM raw.transactions_train
WHERE t_dat >= DATE '2020-01-01'
GROUP BY 1
ORDER BY 1;

\--    Result: channel 1 drops to zero in April 2020, so 1 = store and 2 = online.
