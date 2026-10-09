SELECT *
FROM {{ ref('stg_sales') }}
WHERE ABS(extended_amount - (order_quantity * unit_price))
  > {{ var('monetary_tolerance') }}

