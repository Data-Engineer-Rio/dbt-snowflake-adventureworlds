WITH selected_batch AS (
  SELECT
    {{ clean_string('raw.channel') }} AS channel,
    TRY_TO_NUMBER(raw.sales_order_line_key) AS sales_order_line_key,
    {{ clean_string('raw.sales_order') }} AS sales_order_number,
    {{ clean_string('raw.sales_order_line') }} AS sales_order_line_label,
    {{ extract_batch_id('raw.source_file') }} AS batch_id,
    raw.source_file,
    raw.source_row_number,
    raw.source_file_content_key,
    raw.source_file_last_modified,
    raw.ingested_at
  FROM {{ source('adventureworks_raw', 'sales_order_raw') }} AS raw
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

