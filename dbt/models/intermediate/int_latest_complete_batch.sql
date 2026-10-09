{{ config(materialized='table') }}

WITH latest_or_missing AS (
  SELECT
    batch_id,
    batch_date,
    dataset_count,
    non_empty_dataset_count,
    file_count,
    total_raw_rows,
    first_ingested_at,
    last_ingested_at,
    is_complete
  FROM {{ ref('int_latest_observed_batch') }}

  UNION ALL

  SELECT
    '__NO_BATCH__',
    NULL,
    0,
    0,
    0,
    0,
    NULL,
    NULL,
    FALSE
  WHERE NOT EXISTS (
    SELECT 1 FROM {{ ref('int_latest_observed_batch') }}
  )
)

SELECT
  *,
  1 / IFF(
    is_complete AND batch_id <> 'UNBATCHED' AND batch_date IS NOT NULL,
    1,
    0
  )
    AS completeness_gate
FROM latest_or_missing
