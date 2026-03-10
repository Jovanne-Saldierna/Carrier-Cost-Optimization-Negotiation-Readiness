WITH first_purchase AS (
    SELECT
        o.customer_id,
        MIN(CAST(o.order_date AS DATE))                            AS first_order_date,
        DATE_TRUNC('month', MIN(CAST(o.order_date AS DATE)))       AS cohort_month
    FROM orders AS o
    GROUP BY
        o.customer_id
),

order_activity AS (
    SELECT
        o.customer_id,
        CAST(o.order_date AS DATE)                                 AS order_date,
        DATE_TRUNC('month', CAST(o.order_date AS DATE))            AS order_month
    FROM orders AS o
),

cohort_activity AS (
    SELECT
        fp.cohort_month,
        oa.order_month,
        oa.customer_id,
        (
            EXTRACT(YEAR FROM oa.order_month) * 12
            + EXTRACT(MONTH FROM oa.order_month)
        ) - (
            EXTRACT(YEAR FROM fp.cohort_month) * 12
            + EXTRACT(MONTH FROM fp.cohort_month)
        )                                                          AS months_since_cohort_start
    FROM first_purchase AS fp
    INNER JOIN order_activity AS oa
        ON fp.customer_id = oa.customer_id
),

cohort_sizes AS (
    SELECT
        cohort_month,
        COUNT(DISTINCT customer_id)                                AS cohort_size
    FROM first_purchase
    GROUP BY
        cohort_month
),

final AS (
    SELECT
        ca.cohort_month,
        ca.order_month,
        ca.months_since_cohort_start,
        COUNT(DISTINCT ca.customer_id)                             AS active_customers,
        cs.cohort_size,
        ROUND(
            COUNT(DISTINCT ca.customer_id) * 100.0
            / NULLIF(cs.cohort_size, 0),
            2
        )                                                          AS retention_rate
    FROM cohort_activity AS ca
    INNER JOIN cohort_sizes AS cs
        ON ca.cohort_month = cs.cohort_month
    GROUP BY
        ca.cohort_month,
        ca.order_month,
        ca.months_since_cohort_start,
        cs.cohort_size
)

SELECT
    cohort_month,
    order_month,
    months_since_cohort_start,
    active_customers,
    cohort_size,
    retention_rate
FROM final
ORDER BY
    cohort_month,
    months_since_cohort_start;
