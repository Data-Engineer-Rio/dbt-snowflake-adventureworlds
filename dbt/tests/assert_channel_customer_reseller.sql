SELECT *
FROM {{ ref('int_sales_order_line') }}
WHERE (channel = 'Internet' AND (customer_key = -1 OR reseller_key <> -1))
   OR (channel = 'Reseller' AND (reseller_key = -1 OR customer_key <> -1))

