SELECT
  date_key,
  date_value,
  fiscal_year,
  fiscal_quarter,
  month_name,
  month_key,
  full_date_label,
  YEAR(date_value) AS calendar_year,
  QUARTER(date_value) AS calendar_quarter,
  MONTH(date_value) AS calendar_month,
  DAY(date_value) AS calendar_day,
  DAYOFWEEKISO(date_value) AS iso_day_of_week,
  batch_id,
  ingested_at AS source_ingested_at
FROM {{ ref('stg_date') }}

