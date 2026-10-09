WITH versions AS (
  SELECT
    'customer' AS dimension_name,
    customer_key::VARCHAR AS natural_key,
    valid_from,
    valid_to,
    LAG(valid_to) OVER (
      PARTITION BY customer_key ORDER BY valid_from
    ) AS prior_valid_to
  FROM {{ ref('dim_customer') }}

  UNION ALL

  SELECT
    'reseller', reseller_key::VARCHAR, valid_from, valid_to,
    LAG(valid_to) OVER (
      PARTITION BY reseller_key ORDER BY valid_from
    )
  FROM {{ ref('dim_reseller') }}

  UNION ALL

  SELECT
    'product', product_key::VARCHAR, valid_from, valid_to,
    LAG(valid_to) OVER (
      PARTITION BY product_key ORDER BY valid_from
    )
  FROM {{ ref('dim_product') }}

  UNION ALL

  SELECT
    'sales_territory', sales_territory_key::VARCHAR, valid_from, valid_to,
    LAG(valid_to) OVER (
      PARTITION BY sales_territory_key ORDER BY valid_from
    )
  FROM {{ ref('dim_sales_territory') }}
)

SELECT *
FROM versions
WHERE prior_valid_to > valid_from

