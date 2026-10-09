SELECT *
FROM {{ ref('int_batch_status') }}
QUALIFY ROW_NUMBER() OVER (
  ORDER BY last_ingested_at DESC, batch_id DESC
) = 1

