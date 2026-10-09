SELECT
  sales.sales_order_line_key,
  orders.sales_order_number,
  orders.sales_order_line_label,
  orders.channel,
  sales.reseller_key,
  sales.customer_key,
  sales.product_key,
  sales.order_date_key,
  sales.due_date_key,
  sales.ship_date_key,
  sales.sales_territory_key,
  sales.order_quantity,
  sales.unit_price,
  sales.extended_amount,
  sales.unit_price_discount_pct,
  sales.product_standard_cost,
  sales.total_product_cost,
  sales.sales_amount,
  ROUND(sales.extended_amount - sales.sales_amount, 4) AS discount_amount,
  ROUND(sales.sales_amount - sales.total_product_cost, 4) AS gross_profit_amount,
  sales.batch_id,
  sales.source_file AS sales_source_file,
  orders.source_file AS order_source_file,
  GREATEST(sales.ingested_at, orders.ingested_at) AS ingested_at
FROM {{ ref('stg_sales') }} AS sales
INNER JOIN {{ ref('stg_sales_order') }} AS orders
  ON sales.sales_order_line_key = orders.sales_order_line_key

