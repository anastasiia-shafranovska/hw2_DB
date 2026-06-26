-- PostgreSQL Optimization Demo
-- Use EXPLAIN or EXPLAIN ANALYZE before each query to compare execution plans.

-- ============================================================
-- 1. Non-optimized query
-- ============================================================

EXPLAIN ANALYZE
SELECT
    (
        SELECT CONCAT(product_name, ': ', cnt)
        FROM (
            SELECT product_name, COUNT(*) AS cnt
            FROM (
                SELECT
                    o.order_id,
                    o.order_date,
                    p.product_id,
                    p.product_name,
                    c.id AS client_id
                FROM opt_orders AS o
                JOIN opt_products AS p
                    ON o.product_id = p.product_id
                JOIN opt_clients AS c
                    ON o.client_id = c.id
                WHERE o.order_date > DATE '2023-01-01'
                  AND c.status = 'active'
            ) AS sub1
            GROUP BY product_name
        ) AS sub2
        WHERE cnt = (
            SELECT MIN(cnt)
            FROM (
                SELECT COUNT(*) AS cnt
                FROM (
                    SELECT
                        o.order_id,
                        o.order_date,
                        p.product_id,
                        p.product_name,
                        c.id AS client_id
                    FROM opt_orders AS o
                    JOIN opt_products AS p
                        ON o.product_id = p.product_id
                    JOIN opt_clients AS c
                        ON o.client_id = c.id
                    WHERE o.order_date > DATE '2023-01-01'
                      AND c.status = 'active'
                ) AS sub3
                GROUP BY product_name
            ) AS sub4
        )
        LIMIT 1
    ) AS min_cnt,

    (
        SELECT CONCAT(product_name, ': ', cnt)
        FROM (
            SELECT product_name, COUNT(*) AS cnt
            FROM (
                SELECT
                    o.order_id,
                    o.order_date,
                    p.product_id,
                    p.product_name,
                    c.id AS client_id
                FROM opt_orders AS o
                JOIN opt_products AS p
                    ON o.product_id = p.product_id
                JOIN opt_clients AS c
                    ON o.client_id = c.id
                WHERE o.order_date > DATE '2023-01-01'
                  AND c.status = 'active'
            ) AS sub1
            GROUP BY product_name
        ) AS sub2
        WHERE cnt = (
            SELECT MAX(cnt)
            FROM (
                SELECT COUNT(*) AS cnt
                FROM (
                    SELECT
                        o.order_id,
                        o.order_date,
                        p.product_id,
                        p.product_name,
                        c.id AS client_id
                    FROM opt_orders AS o
                    JOIN opt_products AS p
                        ON o.product_id = p.product_id
                    JOIN opt_clients AS c
                        ON o.client_id = c.id
                    WHERE o.order_date > DATE '2023-01-01'
                      AND c.status = 'active'
                ) AS sub3
                GROUP BY product_name
            ) AS sub4
        )
        LIMIT 1
    ) AS max_cnt;


-- ============================================================
-- 2. Indexes for optimization
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_opt_orders_order_date
    ON opt_orders(order_date);

CREATE INDEX IF NOT EXISTS idx_opt_orders_product_id
    ON opt_orders(product_id);

CREATE INDEX IF NOT EXISTS idx_opt_orders_client_id
    ON opt_orders(client_id);

CREATE INDEX IF NOT EXISTS idx_opt_clients_status
    ON opt_clients(status);


-- ============================================================
-- 3. Optimized query
-- ============================================================

EXPLAIN ANALYZE
WITH filtered_orders AS (
    SELECT
        o.order_id,
        o.order_date,
        p.product_id,
        p.product_name,
        c.id AS client_id
    FROM opt_orders AS o
    JOIN opt_products AS p
        ON o.product_id = p.product_id
    JOIN opt_clients AS c
        ON o.client_id = c.id
    WHERE o.order_date > DATE '2023-01-01'
      AND c.status = 'active'
),
cnt_products AS (
    SELECT
        product_name,
        COUNT(*) AS cnt
    FROM filtered_orders
    GROUP BY product_name
),
ranked_products AS (
    SELECT
        product_name,
        cnt,
        ROW_NUMBER() OVER (ORDER BY cnt ASC, product_name ASC) AS min_rn,
        ROW_NUMBER() OVER (ORDER BY cnt DESC, product_name ASC) AS max_rn
    FROM cnt_products
)
SELECT
    MAX(CONCAT(product_name, ': ', cnt)) FILTER (WHERE min_rn = 1) AS min_cnt,
    MAX(CONCAT(product_name, ': ', cnt)) FILTER (WHERE max_rn = 1) AS max_cnt
FROM ranked_products;






-- ============================================================
-- Bonus +2

SET enable_indexscan = OFF;
SET enable_indexonlyscan = OFF;



EXPLAIN ANALYZE
WITH filtered_orders AS (
    SELECT
        o.order_id,
        o.order_date,
        p.product_id,
        p.product_name,
        c.id AS client_id
    FROM opt_orders AS o
    JOIN opt_products AS p
        ON o.product_id = p.product_id
    JOIN opt_clients AS c
        ON o.client_id = c.id
    WHERE o.order_date > DATE '2021-12-26'
      AND c.status = 'active'
),
cnt_products AS (
    SELECT
        product_name,
        COUNT(*) AS cnt
    FROM filtered_orders
    GROUP BY product_name
),
ranked_products AS (
    SELECT
        product_name,
        cnt,
        ROW_NUMBER() OVER (ORDER BY cnt ASC, product_name ASC) AS min_rn,
        ROW_NUMBER() OVER (ORDER BY cnt DESC, product_name ASC) AS max_rn
    FROM cnt_products
)
SELECT
    MAX(CONCAT(product_name, ': ', cnt)) FILTER (WHERE min_rn = 1) AS min_cnt,
    MAX(CONCAT(product_name, ': ', cnt)) FILTER (WHERE max_rn = 1) AS max_cnt
FROM ranked_products;

