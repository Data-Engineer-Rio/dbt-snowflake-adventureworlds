WITH joined AS (
  SELECT
    COALESCE(sales.sales_order_line_key, orders.sales_order_line_key)
      AS sales_order_line_key,
    sales.sales_order_line_key IS NULL AS missing_sales,
    orders.sales_order_line_key IS NULL AS missing_order
  FROM {{ ref('stg_sales') }} AS sales
  FULL OUTER JOIN {{ ref('stg_sales_order') }} AS orders
    ON sales.sales_order_line_key = orders.sales_order_line_key
)

SELECT *
FROM joined
WHERE missing_sales OR missing_order

