SELECT
  dbt_scd_id AS customer_version_key,
  customer_key,
  customer_id,
  customer_name,
  city,
  state_province,
  country_region,
  postal_code,
  batch_id AS observed_batch_id,
  dbt_valid_from AS valid_from,
  COALESCE(dbt_valid_to, '9999-12-31'::TIMESTAMP_NTZ) AS valid_to,
  dbt_valid_to IS NULL AS is_current
FROM {{ ref('snap_customer') }}

