WITH aggregated AS (
  SELECT
    batch_id,
    MAX(batch_date) AS batch_date,
    COUNT(DISTINCT dataset_name) AS dataset_count,
    COUNT(DISTINCT IFF(row_count > 0, dataset_name, NULL))
      AS non_empty_dataset_count,
    COUNT(DISTINCT source_file) AS file_count,
    SUM(row_count) AS total_raw_rows,
    MIN(first_ingested_at) AS first_ingested_at,
    MAX(last_ingested_at) AS last_ingested_at
  FROM {{ ref('int_batch_file_inventory') }}
  GROUP BY batch_id
)

SELECT
  *,
  dataset_count = {{ var('expected_dataset_count') }}
    AND non_empty_dataset_count = {{ var('expected_dataset_count') }}
    AND file_count = {{ var('expected_dataset_count') }}
    AND batch_date IS NOT NULL
    AS is_complete
FROM aggregated
