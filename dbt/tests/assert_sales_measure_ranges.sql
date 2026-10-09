SELECT *
FROM {{ ref('stg_sales') }}
WHERE order_quantity <= 0
   OR unit_price < 0
   OR extended_amount < 0
   OR product_standard_cost < 0
   OR total_product_cost < 0
   OR sales_amount < 0
   OR sales_amount > extended_amount + {{ var('monetary_tolerance') }}
   OR unit_price_discount_pct < 0
   OR unit_price_discount_pct > 1
