SELECT
  dbt_scd_id AS product_version_key,
  product_key,
  sku,
  product_name,
  standard_cost,
  color,
  list_price,
  model,
  subcategory,
  category,
  batch_id AS observed_batch_id,
  dbt_valid_from AS valid_from,
  COALESCE(dbt_valid_to, '9999-12-31'::TIMESTAMP_NTZ) AS valid_to,
  dbt_valid_to IS NULL AS is_current
FROM {{ ref('snap_product') }}

