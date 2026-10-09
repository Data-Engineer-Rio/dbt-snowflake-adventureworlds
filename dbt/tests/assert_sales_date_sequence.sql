SELECT *
FROM {{ ref('fct_sales_order_line') }}
WHERE order_date > due_date
   OR order_date > ship_date

