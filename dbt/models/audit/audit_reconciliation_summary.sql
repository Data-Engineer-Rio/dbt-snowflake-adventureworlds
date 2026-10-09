WITH source_metrics AS (
  SELECT
    MAX(batch_id) AS batch_id,
    COUNT(*)::NUMBER(38, 4) AS row_count,
    COUNT(DISTINCT sales_order_line_key)::NUMBER(38, 4) AS distinct_key_count,
    SUM(order_quantity)::NUMBER(38, 4) AS order_quantity,
    SUM(extended_amount)::NUMBER(38, 4) AS extended_amount,
    SUM(total_product_cost)::NUMBER(38, 4) AS total_product_cost,
    SUM(sales_amount)::NUMBER(38, 4) AS sales_amount
  FROM {{ ref('int_sales_order_line') }}
),

target_metrics AS (
  SELECT
    COUNT(*)::NUMBER(38, 4) AS row_count,
    COUNT(DISTINCT sales_order_line_key)::NUMBER(38, 4) AS distinct_key_count,
    SUM(order_quantity)::NUMBER(38, 4) AS order_quantity,
    SUM(extended_amount)::NUMBER(38, 4) AS extended_amount,
    SUM(total_product_cost)::NUMBER(38, 4) AS total_product_cost,
    SUM(sales_amount)::NUMBER(38, 4) AS sales_amount
  FROM {{ ref('fct_sales_order_line') }}
),

source_keys_missing_from_fact AS (
  SELECT COUNT(*)::NUMBER(38, 4) AS missing_count
  FROM {{ ref('int_sales_order_line') }} AS source
  LEFT JOIN {{ ref('fct_sales_order_line') }} AS target
    ON source.sales_order_line_key = target.sales_order_line_key
  WHERE target.sales_order_line_key IS NULL
),

fact_keys_missing_from_source AS (
  SELECT COUNT(*)::NUMBER(38, 4) AS missing_count
  FROM {{ ref('fct_sales_order_line') }} AS target
  LEFT JOIN {{ ref('int_sales_order_line') }} AS source
    ON target.sales_order_line_key = source.sales_order_line_key
  WHERE source.sales_order_line_key IS NULL
),

hash_mismatches AS (
  SELECT COUNT(*)::NUMBER(38, 4) AS mismatch_count
  FROM {{ ref('int_sales_order_line') }} AS source
  INNER JOIN {{ ref('fct_sales_order_line') }} AS target
    ON source.sales_order_line_key = target.sales_order_line_key
  WHERE MD5(CONCAT_WS(
    '||',
    source.sales_order_line_key,
    source.product_key,
    source.order_quantity,
    source.unit_price,
    source.extended_amount,
    source.total_product_cost,
    source.sales_amount
  )) <> target.record_hash
),

metrics AS (
  SELECT
    source.batch_id,
    'ROW_COUNT' AS metric_name,
    source.row_count AS source_value,
    target.row_count AS target_value,
    0::NUMBER(38, 4) AS tolerance
  FROM source_metrics AS source
  CROSS JOIN target_metrics AS target

  UNION ALL

  SELECT
    source.batch_id,
    'DISTINCT_KEY_COUNT',
    source.distinct_key_count,
    target.distinct_key_count,
    0
  FROM source_metrics AS source
  CROSS JOIN target_metrics AS target

  UNION ALL

  SELECT
    source.batch_id,
    'ORDER_QUANTITY',
    source.order_quantity,
    target.order_quantity,
    0
  FROM source_metrics AS source
  CROSS JOIN target_metrics AS target

  UNION ALL

  SELECT
    source.batch_id,
    'EXTENDED_AMOUNT',
    source.extended_amount,
    target.extended_amount,
    {{ var('monetary_tolerance') }}
  FROM source_metrics AS source
  CROSS JOIN target_metrics AS target

  UNION ALL

  SELECT
    source.batch_id,
    'TOTAL_PRODUCT_COST',
    source.total_product_cost,
    target.total_product_cost,
    {{ var('monetary_tolerance') }}
  FROM source_metrics AS source
  CROSS JOIN target_metrics AS target

  UNION ALL

  SELECT
    source.batch_id,
    'SALES_AMOUNT',
    source.sales_amount,
    target.sales_amount,
    {{ var('monetary_tolerance') }}
  FROM source_metrics AS source
  CROSS JOIN target_metrics AS target

  UNION ALL

  SELECT
    source.batch_id,
    'SOURCE_KEYS_NOT_IN_FACT',
    missing.missing_count,
    0,
    0
  FROM source_metrics AS source
  CROSS JOIN source_keys_missing_from_fact AS missing

  UNION ALL

  SELECT
    source.batch_id,
    'FACT_KEYS_NOT_IN_SOURCE',
    missing.missing_count,
    0,
    0
  FROM source_metrics AS source
  CROSS JOIN fact_keys_missing_from_source AS missing

  UNION ALL

  SELECT
    source.batch_id,
    'HASH_MISMATCH_COUNT',
    mismatches.mismatch_count,
    0,
    0
  FROM source_metrics AS source
  CROSS JOIN hash_mismatches AS mismatches
)

SELECT
  batch_id,
  metric_name,
  source_value,
  target_value,
  target_value - source_value AS difference,
  tolerance,
  IFF(ABS(target_value - source_value) <= tolerance, 'PASS', 'FAIL') AS status,
  CURRENT_TIMESTAMP() AS checked_at
FROM metrics

