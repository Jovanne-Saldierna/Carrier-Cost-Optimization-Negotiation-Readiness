WITH product_orders AS (
    SELECT
        o.order_id,
        CAST(o.order_date AS DATE)                                 AS order_date,
        o.customer_id,
        o.product_id,
        p.product_name,
        p.category,
        o.channel,
        o.quantity,
        o.unit_price,
        (o.quantity * o.unit_price)                                AS order_revenue
    FROM orders AS o
    INNER JOIN products AS p
        ON o.product_id = p.product_id
),

final AS (
    SELECT
        product_id,
        product_name,
        category,
        COUNT(DISTINCT order_id)                                   AS total_orders,
        COUNT(DISTINCT customer_id)                                AS purchasing_customers,
        SUM(quantity)                                              AS total_units_sold,
        SUM(order_revenue)                                         AS total_revenue,
        ROUND(AVG(order_revenue), 2)                               AS avg_order_value
    FROM product_orders
    GROUP BY
        product_id,
        product_name,
        category
)

SELECT
    product_id,
    product_name,
    category,
    total_orders,
    purchasing_customers,
    total_units_sold,
    total_revenue,
    avg_order_value,
    RANK() OVER (ORDER BY total_revenue DESC)                      AS revenue_rank
FROM final
ORDER BY
    revenue_rank;
