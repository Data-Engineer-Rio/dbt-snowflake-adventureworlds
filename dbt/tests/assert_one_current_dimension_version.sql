WITH failures AS (
  SELECT 'customer' AS dimension_name, customer_key::VARCHAR AS natural_key
  FROM {{ ref('dim_customer') }}
  GROUP BY customer_key
  HAVING COUNT_IF(is_current) <> 1

  UNION ALL

  SELECT 'reseller', reseller_key::VARCHAR
  FROM {{ ref('dim_reseller') }}
  GROUP BY reseller_key
  HAVING COUNT_IF(is_current) <> 1

  UNION ALL

  SELECT 'product', product_key::VARCHAR
  FROM {{ ref('dim_product') }}
  GROUP BY product_key
  HAVING COUNT_IF(is_current) <> 1

  UNION ALL

  SELECT 'sales_territory', sales_territory_key::VARCHAR
  FROM {{ ref('dim_sales_territory') }}
  GROUP BY sales_territory_key
  HAVING COUNT_IF(is_current) <> 1
)

SELECT *
FROM failures

