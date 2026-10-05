-- Clean version of the articles table.
-- Keeps only the columns used in this project, with shorter names.
CREATE OR REPLACE TABLE clean.articles AS
SELECT
    article_id,
    prod_name          AS product_name,
    product_type_name  AS product_type,
    product_group_name AS product_group,
    index_group_name   AS index_group,
    department_name    AS department
FROM raw.articles;

-- Quick check: number of articles in each index group
SELECT index_group, COUNT(*) AS articles
FROM clean.articles
GROUP BY index_group
ORDER BY articles DESC
