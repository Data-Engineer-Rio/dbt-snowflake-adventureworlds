{{
  config(
    materialized='incremental',
    unique_key='sales_order_line_key',
    incremental_strategy='merge',
    on_schema_change='sync_all_columns'
  )
}}

WITH sales AS (
  SELECT *
  FROM {{ ref('int_sales_order_line') }}
),

current_customer AS (
  SELECT customer_key, customer_version_key
  FROM {{ ref('dim_customer') }}
  WHERE is_current
),

current_reseller AS (
  SELECT reseller_key, reseller_version_key
  FROM {{ ref('dim_reseller') }}
  WHERE is_current
),

current_product AS (
  SELECT product_key, product_version_key
  FROM {{ ref('dim_product') }}
  WHERE is_current
),

current_territory AS (
  SELECT sales_territory_key, sales_territory_version_key
  FROM {{ ref('dim_sales_territory') }}
  WHERE is_current
)

SELECT
  sales.sales_order_line_key,
  sales.sales_order_number,
  sales.sales_order_line_label,
  sales.channel,
  sales.customer_key,
  customer.customer_version_key,
  sales.reseller_key,
  reseller.reseller_version_key,
  sales.product_key,
  product.product_version_key,
  sales.sales_territory_key,
  territory.sales_territory_version_key,
  sales.order_date_key,
  order_date.date_value AS order_date,
  sales.due_date_key,
  due_date.date_value AS due_date,
  sales.ship_date_key,
  ship_date.date_value AS ship_date,
  sales.order_quantity,
  sales.unit_price,
  sales.extended_amount,
  sales.unit_price_discount_pct,
  sales.product_standard_cost,
  sales.total_product_cost,
  sales.sales_amount,
  sales.discount_amount,
  sales.gross_profit_amount,
  sales.batch_id,
  sales.sales_source_file,
  sales.order_source_file,
  sales.ingested_at AS source_ingested_at,
  MD5(CONCAT_WS(
    '||',
    sales.sales_order_line_key,
    sales.product_key,
    sales.order_quantity,
    sales.unit_price,
    sales.extended_amount,
    sales.total_product_cost,
    sales.sales_amount
  )) AS record_hash,
  CURRENT_TIMESTAMP() AS warehouse_updated_at
FROM sales
INNER JOIN {{ ref('dim_date') }} AS order_date
  ON sales.order_date_key = order_date.date_key
INNER JOIN {{ ref('dim_date') }} AS due_date
  ON sales.due_date_key = due_date.date_key
LEFT JOIN {{ ref('dim_date') }} AS ship_date
  ON sales.ship_date_key = ship_date.date_key
INNER JOIN current_customer AS customer
  ON sales.customer_key = customer.customer_key
INNER JOIN current_reseller AS reseller
  ON sales.reseller_key = reseller.reseller_key
INNER JOIN current_product AS product
  ON sales.product_key = product.product_key
INNER JOIN current_territory AS territory
  ON sales.sales_territory_key = territory.sales_territory_key

