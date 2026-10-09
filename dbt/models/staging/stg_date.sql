WITH selected_batch AS (
  SELECT
    TRY_TO_NUMBER(raw.date_key) AS date_key,
    TRY_TO_DATE(raw.date_value) AS date_value,
    {{ clean_string('raw.fiscal_year') }} AS fiscal_year,
    {{ clean_string('raw.fiscal_quarter') }} AS fiscal_quarter,
    {{ clean_string('raw.month_name') }} AS month_name,
    {{ clean_string('raw.full_date') }} AS full_date_label,
    TRY_TO_NUMBER(raw.month_key) AS month_key,
    {{ extract_batch_id('raw.source_file') }} AS batch_id,
    raw.source_file,
    raw.source_row_number,
    raw.source_file_content_key,
    raw.source_file_last_modified,
    raw.ingested_at
  FROM {{ source('adventureworks_raw', 'date_raw') }} AS raw
  INNER JOIN {{ ref('int_latest_complete_batch') }} AS batch
    ON {{ extract_batch_id('raw.source_file') }} = batch.batch_id
)

SELECT *
FROM selected_batch
QUALIFY ROW_NUMBER() OVER (
  PARTITION BY date_key
  ORDER BY
    ingested_at DESC,
    source_file_last_modified DESC,
    source_row_number DESC
) = 1

