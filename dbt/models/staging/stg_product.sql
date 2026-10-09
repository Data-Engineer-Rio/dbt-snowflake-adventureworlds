WITH selected_batch AS (
  SELECT
    TRY_TO_NUMBER(raw.product_key) AS product_key,
    {{ clean_string('raw.sku') }} AS sku,
    {{ clean_string('raw.product_name') }} AS product_name,
    ROUND(TRY_TO_DECIMAL(raw.standard_cost, 38, 10), 4) AS standard_cost,
    {{ clean_string('raw.color') }} AS color,
    ROUND(TRY_TO_DECIMAL(raw.list_price, 38, 10), 4) AS list_price,
    {{ clean_string('raw.model') }} AS model,
    {{ clean_string('raw.subcategory') }} AS subcategory,
    {{ clean_string('raw.category') }} AS category,
    {{ extract_batch_id('raw.source_file') }} AS batch_id,
    raw.source_file,
    raw.source_row_number,
    raw.source_file_content_key,
    raw.source_file_last_modified,
    raw.ingested_at
  FROM {{ source('adventureworks_raw', 'product_raw') }} AS raw
  INNER JOIN {{ ref('int_latest_complete_batch') }} AS batch
    ON {{ extract_batch_id('raw.source_file') }} = batch.batch_id
)

SELECT *
FROM selected_batch
QUALIFY ROW_NUMBER() OVER (
  PARTITION BY product_key
  ORDER BY
    ingested_at DESC,
    source_file_last_modified DESC,
    source_row_number DESC
) = 1

