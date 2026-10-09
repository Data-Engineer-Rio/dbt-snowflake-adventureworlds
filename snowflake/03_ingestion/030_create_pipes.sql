USE ROLE AW_INGEST_ROLE;

CREATE PIPE IF NOT EXISTS ADVENTUREWORKS_DE.LANDING.SALES_PIPE
  AUTO_INGEST = TRUE
AS
COPY INTO ADVENTUREWORKS_DE.RAW.SALES_RAW (
  sales_order_line_key,
  reseller_key,
  customer_key,
  product_key,
  order_date_key,
  due_date_key,
  ship_date_key,
  sales_territory_key,
  order_quantity,
  unit_price,
  extended_amount,
  unit_price_discount_pct,
  product_standard_cost,
  total_product_cost,
  sales_amount,
  source_file,
  source_row_number,
  source_file_content_key,
  source_file_last_modified,
  ingested_at
)
FROM (
  SELECT
    t.$1, t.$2, t.$3, t.$4, t.$5,
    t.$6, t.$7, t.$8, t.$9, t.$10,
    t.$11, t.$12, t.$13, t.$14, t.$15,
    METADATA$FILENAME,
    METADATA$FILE_ROW_NUMBER,
    METADATA$FILE_CONTENT_KEY,
    METADATA$FILE_LAST_MODIFIED,
    METADATA$START_SCAN_TIME
  FROM @ADVENTUREWORKS_DE.LANDING.AW_S3_STAGE
    (FILE_FORMAT => ADVENTUREWORKS_DE.LANDING.AW_CSV_FORMAT) t
)
PATTERN = '.*sales_data[.]csv$'
ON_ERROR = 'ABORT_STATEMENT';

CREATE PIPE IF NOT EXISTS ADVENTUREWORKS_DE.LANDING.SALES_ORDER_PIPE
  AUTO_INGEST = TRUE
AS
COPY INTO ADVENTUREWORKS_DE.RAW.SALES_ORDER_RAW (
  channel,
  sales_order_line_key,
  sales_order,
  sales_order_line,
  source_file,
  source_row_number,
  source_file_content_key,
  source_file_last_modified,
  ingested_at
)
FROM (
  SELECT
    t.$1, t.$2, t.$3, t.$4,
    METADATA$FILENAME,
    METADATA$FILE_ROW_NUMBER,
    METADATA$FILE_CONTENT_KEY,
    METADATA$FILE_LAST_MODIFIED,
    METADATA$START_SCAN_TIME
  FROM @ADVENTUREWORKS_DE.LANDING.AW_S3_STAGE
    (FILE_FORMAT => ADVENTUREWORKS_DE.LANDING.AW_CSV_FORMAT) t
)
PATTERN = '.*sales_order_data[.]csv$'
ON_ERROR = 'ABORT_STATEMENT';

CREATE PIPE IF NOT EXISTS ADVENTUREWORKS_DE.LANDING.CUSTOMER_PIPE
  AUTO_INGEST = TRUE
AS
COPY INTO ADVENTUREWORKS_DE.RAW.CUSTOMER_RAW (
  customer_key,
  customer_id,
  customer_name,
  city,
  state_province,
  country_region,
  postal_code,
  source_file,
  source_row_number,
  source_file_content_key,
  source_file_last_modified,
  ingested_at
)
FROM (
  SELECT
    t.$1, t.$2, t.$3, t.$4, t.$5, t.$6, t.$7,
    METADATA$FILENAME,
    METADATA$FILE_ROW_NUMBER,
    METADATA$FILE_CONTENT_KEY,
    METADATA$FILE_LAST_MODIFIED,
    METADATA$START_SCAN_TIME
  FROM @ADVENTUREWORKS_DE.LANDING.AW_S3_STAGE
    (FILE_FORMAT => ADVENTUREWORKS_DE.LANDING.AW_CSV_FORMAT) t
)
PATTERN = '.*customer_data[.]csv$'
ON_ERROR = 'ABORT_STATEMENT';

CREATE PIPE IF NOT EXISTS ADVENTUREWORKS_DE.LANDING.RESELLER_PIPE
  AUTO_INGEST = TRUE
AS
COPY INTO ADVENTUREWORKS_DE.RAW.RESELLER_RAW (
  reseller_key,
  reseller_id,
  business_type,
  reseller_name,
  city,
  state_province,
  country_region,
  postal_code,
  source_file,
  source_row_number,
  source_file_content_key,
  source_file_last_modified,
  ingested_at
)
FROM (
  SELECT
    t.$1, t.$2, t.$3, t.$4, t.$5, t.$6, t.$7, t.$8,
    METADATA$FILENAME,
    METADATA$FILE_ROW_NUMBER,
    METADATA$FILE_CONTENT_KEY,
    METADATA$FILE_LAST_MODIFIED,
    METADATA$START_SCAN_TIME
  FROM @ADVENTUREWORKS_DE.LANDING.AW_S3_STAGE
    (FILE_FORMAT => ADVENTUREWORKS_DE.LANDING.AW_CSV_FORMAT) t
)
PATTERN = '.*reseller_data[.]csv$'
ON_ERROR = 'ABORT_STATEMENT';

CREATE PIPE IF NOT EXISTS ADVENTUREWORKS_DE.LANDING.PRODUCT_PIPE
  AUTO_INGEST = TRUE
AS
COPY INTO ADVENTUREWORKS_DE.RAW.PRODUCT_RAW (
  product_key,
  sku,
  product_name,
  standard_cost,
  color,
  list_price,
  model,
  subcategory,
  category,
  source_file,
  source_row_number,
  source_file_content_key,
  source_file_last_modified,
  ingested_at
)
FROM (
  SELECT
    t.$1, t.$2, t.$3, t.$4, t.$5, t.$6, t.$7, t.$8, t.$9,
    METADATA$FILENAME,
    METADATA$FILE_ROW_NUMBER,
    METADATA$FILE_CONTENT_KEY,
    METADATA$FILE_LAST_MODIFIED,
    METADATA$START_SCAN_TIME
  FROM @ADVENTUREWORKS_DE.LANDING.AW_S3_STAGE
    (FILE_FORMAT => ADVENTUREWORKS_DE.LANDING.AW_CSV_FORMAT) t
)
PATTERN = '.*product_data[.]csv$'
ON_ERROR = 'ABORT_STATEMENT';

CREATE PIPE IF NOT EXISTS ADVENTUREWORKS_DE.LANDING.DATE_PIPE
  AUTO_INGEST = TRUE
AS
COPY INTO ADVENTUREWORKS_DE.RAW.DATE_RAW (
  date_key,
  date_value,
  fiscal_year,
  fiscal_quarter,
  month_name,
  full_date,
  month_key,
  source_file,
  source_row_number,
  source_file_content_key,
  source_file_last_modified,
  ingested_at
)
FROM (
  SELECT
    t.$1, t.$2, t.$3, t.$4, t.$5, t.$6, t.$7,
    METADATA$FILENAME,
    METADATA$FILE_ROW_NUMBER,
    METADATA$FILE_CONTENT_KEY,
    METADATA$FILE_LAST_MODIFIED,
    METADATA$START_SCAN_TIME
  FROM @ADVENTUREWORKS_DE.LANDING.AW_S3_STAGE
    (FILE_FORMAT => ADVENTUREWORKS_DE.LANDING.AW_CSV_FORMAT) t
)
PATTERN = '.*date_data[.]csv$'
ON_ERROR = 'ABORT_STATEMENT';

CREATE PIPE IF NOT EXISTS ADVENTUREWORKS_DE.LANDING.SALES_TERRITORY_PIPE
  AUTO_INGEST = TRUE
AS
COPY INTO ADVENTUREWORKS_DE.RAW.SALES_TERRITORY_RAW (
  sales_territory_key,
  region,
  country,
  territory_group,
  source_file,
  source_row_number,
  source_file_content_key,
  source_file_last_modified,
  ingested_at
)
FROM (
  SELECT
    t.$1, t.$2, t.$3, t.$4,
    METADATA$FILENAME,
    METADATA$FILE_ROW_NUMBER,
    METADATA$FILE_CONTENT_KEY,
    METADATA$FILE_LAST_MODIFIED,
    METADATA$START_SCAN_TIME
  FROM @ADVENTUREWORKS_DE.LANDING.AW_S3_STAGE
    (FILE_FORMAT => ADVENTUREWORKS_DE.LANDING.AW_CSV_FORMAT) t
)
PATTERN = '.*sales_territory_data[.]csv$'
ON_ERROR = 'ABORT_STATEMENT';

SHOW PIPES IN SCHEMA ADVENTUREWORKS_DE.LANDING;

