SELECT
  dbt_scd_id AS sales_territory_version_key,
  sales_territory_key,
  region,
  country,
  territory_group,
  batch_id AS observed_batch_id,
  dbt_valid_from AS valid_from,
  COALESCE(dbt_valid_to, '9999-12-31'::TIMESTAMP_NTZ) AS valid_to,
  dbt_valid_to IS NULL AS is_current
FROM {{ ref('snap_sales_territory') }}

