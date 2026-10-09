WITH selected_batch AS (
  SELECT
    TRY_TO_NUMBER(raw.sales_territory_key) AS sales_territory_key,
    {{ clean_string('raw.region') }} AS region,
    {{ clean_string('raw.country') }} AS country,
    {{ clean_string('raw.territory_group') }} AS territory_group,
    {{ extract_batch_id('raw.source_file') }} AS batch_id,
    raw.source_file,
    raw.source_row_number,
    raw.source_file_content_key,
    raw.source_file_last_modified,
    raw.ingested_at
  FROM {{ source('adventureworks_raw', 'sales_territory_raw') }} AS raw
  INNER JOIN {{ ref('int_latest_complete_batch') }} AS batch
    ON {{ extract_batch_id('raw.source_file') }} = batch.batch_id
)

SELECT *
FROM selected_batch
QUALIFY ROW_NUMBER() OVER (
  PARTITION BY sales_territory_key
  ORDER BY
    ingested_at DESC,
    source_file_last_modified DESC,
    source_row_number DESC
) = 1

