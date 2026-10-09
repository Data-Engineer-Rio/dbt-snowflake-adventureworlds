WITH selected_batch AS (
  SELECT
    TRY_TO_NUMBER(raw.customer_key) AS customer_key,
    {{ clean_string('raw.customer_id') }} AS customer_id,
    {{ clean_string('raw.customer_name') }} AS customer_name,
    {{ clean_string('raw.city') }} AS city,
    {{ clean_string('raw.state_province') }} AS state_province,
    {{ clean_string('raw.country_region') }} AS country_region,
    {{ clean_string('raw.postal_code') }} AS postal_code,
    {{ extract_batch_id('raw.source_file') }} AS batch_id,
    raw.source_file,
    raw.source_row_number,
    raw.source_file_content_key,
    raw.source_file_last_modified,
    raw.ingested_at
  FROM {{ source('adventureworks_raw', 'customer_raw') }} AS raw
  INNER JOIN {{ ref('int_latest_complete_batch') }} AS batch
    ON {{ extract_batch_id('raw.source_file') }} = batch.batch_id
)

SELECT *
FROM selected_batch
QUALIFY ROW_NUMBER() OVER (
  PARTITION BY customer_key
  ORDER BY
    ingested_at DESC,
    source_file_last_modified DESC,
    source_row_number DESC
) = 1

