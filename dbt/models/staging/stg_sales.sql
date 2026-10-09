WITH selected_batch AS (
  SELECT
    TRY_TO_NUMBER(raw.sales_order_line_key) AS sales_order_line_key,
    TRY_TO_NUMBER(raw.reseller_key) AS reseller_key,
    TRY_TO_NUMBER(raw.customer_key) AS customer_key,
    TRY_TO_NUMBER(raw.product_key) AS product_key,
    TRY_TO_NUMBER(raw.order_date_key) AS order_date_key,
    TRY_TO_NUMBER(raw.due_date_key) AS due_date_key,
    TRY_TO_NUMBER(NULLIF(raw.ship_date_key, '')) AS ship_date_key,
    TRY_TO_NUMBER(raw.sales_territory_key) AS sales_territory_key,
    TRY_TO_NUMBER(raw.order_quantity) AS order_quantity,
    ROUND(TRY_TO_DECIMAL(raw.unit_price, 38, 10), 4) AS unit_price,
    ROUND(TRY_TO_DECIMAL(raw.extended_amount, 38, 10), 4) AS extended_amount,
    ROUND(TRY_TO_DECIMAL(raw.unit_price_discount_pct, 38, 10), 6)
      AS unit_price_discount_pct,
    ROUND(TRY_TO_DECIMAL(raw.product_standard_cost, 38, 10), 4)
      AS product_standard_cost,
    ROUND(TRY_TO_DECIMAL(raw.total_product_cost, 38, 10), 4)
      AS total_product_cost,
    ROUND(TRY_TO_DECIMAL(raw.sales_amount, 38, 10), 4) AS sales_amount,
    {{ extract_batch_id('raw.source_file') }} AS batch_id,
    raw.source_file,
    raw.source_row_number,
    raw.source_file_content_key,
    raw.source_file_last_modified,
    raw.ingested_at
  FROM {{ source('adventureworks_raw', 'sales_raw') }} AS raw
  INNER JOIN {{ ref('int_latest_complete_batch') }} AS batch
    ON {{ extract_batch_id('raw.source_file') }} = batch.batch_id
)

SELECT *
FROM selected_batch
QUALIFY ROW_NUMBER() OVER (
  PARTITION BY sales_order_line_key
  ORDER BY
    ingested_at DESC,
    source_file_last_modified DESC,
    source_row_number DESC
) = 1

