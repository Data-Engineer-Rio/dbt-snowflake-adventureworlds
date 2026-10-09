WITH inventory AS (
  SELECT
    'sales' AS dataset_name,
    {{ extract_batch_id('source_file') }} AS batch_id,
    {{ extract_batch_date('source_file') }} AS batch_date,
    source_file,
    COUNT(*) AS row_count,
    MIN(ingested_at) AS first_ingested_at,
    MAX(ingested_at) AS last_ingested_at
  FROM {{ source('adventureworks_raw', 'sales_raw') }}
  GROUP BY ALL

  UNION ALL

  SELECT
    'sales_order',
    {{ extract_batch_id('source_file') }},
    {{ extract_batch_date('source_file') }},
    source_file,
    COUNT(*),
    MIN(ingested_at),
    MAX(ingested_at)
  FROM {{ source('adventureworks_raw', 'sales_order_raw') }}
  GROUP BY ALL

  UNION ALL

  SELECT
    'customer',
    {{ extract_batch_id('source_file') }},
    {{ extract_batch_date('source_file') }},
    source_file,
    COUNT(*),
    MIN(ingested_at),
    MAX(ingested_at)
  FROM {{ source('adventureworks_raw', 'customer_raw') }}
  GROUP BY ALL

  UNION ALL

  SELECT
    'reseller',
    {{ extract_batch_id('source_file') }},
    {{ extract_batch_date('source_file') }},
    source_file,
    COUNT(*),
    MIN(ingested_at),
    MAX(ingested_at)
  FROM {{ source('adventureworks_raw', 'reseller_raw') }}
  GROUP BY ALL

  UNION ALL

  SELECT
    'product',
    {{ extract_batch_id('source_file') }},
    {{ extract_batch_date('source_file') }},
    source_file,
    COUNT(*),
    MIN(ingested_at),
    MAX(ingested_at)
  FROM {{ source('adventureworks_raw', 'product_raw') }}
  GROUP BY ALL

  UNION ALL

  SELECT
    'date',
    {{ extract_batch_id('source_file') }},
    {{ extract_batch_date('source_file') }},
    source_file,
    COUNT(*),
    MIN(ingested_at),
    MAX(ingested_at)
  FROM {{ source('adventureworks_raw', 'date_raw') }}
  GROUP BY ALL

  UNION ALL

  SELECT
    'sales_territory',
    {{ extract_batch_id('source_file') }},
    {{ extract_batch_date('source_file') }},
    source_file,
    COUNT(*),
    MIN(ingested_at),
    MAX(ingested_at)
  FROM {{ source('adventureworks_raw', 'sales_territory_raw') }}
  GROUP BY ALL
)

SELECT *
FROM inventory

