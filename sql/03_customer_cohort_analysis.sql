WITH first_purchase AS (

    SELECT
        customer_id,
        MIN(order_date) AS first_order_date,
        DATE_TRUNC('month', MIN(order_date)) AS cohort_month
    FROM orders
    GROUP BY customer_id

),

orders_with_cohort AS (

    SELECT
        o.customer_id,
        o.order_date,
        DATE_TRUNC('month', o.order_date) AS order_month,
        fp.cohort_month
    FROM orders o
    JOIN first_purchase fp
        ON o.customer_id = fp.customer_id

),

cohort_activity AS (

    SELECT
        cohort_month,
        order_month,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM orders_with_cohort
    GROUP BY cohort_month, order_month

)

SELECT
    cohort_month,
    order_month,
    active_customers
FROM cohort_activity
ORDER BY cohort_month, order_month;
