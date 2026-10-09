SELECT *
FROM {{ ref('stg_sales') }}
WHERE ABS(total_product_cost - (order_quantity * product_standard_cost))
  > {{ var('monetary_tolerance') }}

