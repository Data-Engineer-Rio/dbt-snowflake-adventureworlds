CREATE TABLE IF NOT EXISTS ADVENTUREWORKS_DE.RAW.SALES_RAW (
  sales_order_line_key VARCHAR,
  reseller_key VARCHAR,
  customer_key VARCHAR,
  product_key VARCHAR,
  order_date_key VARCHAR,
  due_date_key VARCHAR,
  ship_date_key VARCHAR,
  sales_territory_key VARCHAR,
  order_quantity VARCHAR,
  unit_price VARCHAR,
  extended_amount VARCHAR,
  unit_price_discount_pct VARCHAR,
  product_standard_cost VARCHAR,
  total_product_cost VARCHAR,
  sales_amount VARCHAR,
  source_file VARCHAR,
  source_row_number NUMBER,
  source_file_content_key VARCHAR,
  source_file_last_modified TIMESTAMP_NTZ,
  ingested_at TIMESTAMP_LTZ
);

CREATE TABLE IF NOT EXISTS ADVENTUREWORKS_DE.RAW.SALES_ORDER_RAW (
  channel VARCHAR,
  sales_order_line_key VARCHAR,
  sales_order VARCHAR,
  sales_order_line VARCHAR,
  source_file VARCHAR,
  source_row_number NUMBER,
  source_file_content_key VARCHAR,
  source_file_last_modified TIMESTAMP_NTZ,
  ingested_at TIMESTAMP_LTZ
);

CREATE TABLE IF NOT EXISTS ADVENTUREWORKS_DE.RAW.CUSTOMER_RAW (
  customer_key VARCHAR,
  customer_id VARCHAR,
  customer_name VARCHAR,
  city VARCHAR,
  state_province VARCHAR,
  country_region VARCHAR,
  postal_code VARCHAR,
  source_file VARCHAR,
  source_row_number NUMBER,
  source_file_content_key VARCHAR,
  source_file_last_modified TIMESTAMP_NTZ,
  ingested_at TIMESTAMP_LTZ
);

CREATE TABLE IF NOT EXISTS ADVENTUREWORKS_DE.RAW.RESELLER_RAW (
  reseller_key VARCHAR,
  reseller_id VARCHAR,
  business_type VARCHAR,
  reseller_name VARCHAR,
  city VARCHAR,
  state_province VARCHAR,
  country_region VARCHAR,
  postal_code VARCHAR,
  source_file VARCHAR,
  source_row_number NUMBER,
  source_file_content_key VARCHAR,
  source_file_last_modified TIMESTAMP_NTZ,
  ingested_at TIMESTAMP_LTZ
);

CREATE TABLE IF NOT EXISTS ADVENTUREWORKS_DE.RAW.PRODUCT_RAW (
  product_key VARCHAR,
  sku VARCHAR,
  product_name VARCHAR,
  standard_cost VARCHAR,
  color VARCHAR,
  list_price VARCHAR,
  model VARCHAR,
  subcategory VARCHAR,
  category VARCHAR,
  source_file VARCHAR,
  source_row_number NUMBER,
  source_file_content_key VARCHAR,
  source_file_last_modified TIMESTAMP_NTZ,
  ingested_at TIMESTAMP_LTZ
);

CREATE TABLE IF NOT EXISTS ADVENTUREWORKS_DE.RAW.DATE_RAW (
  date_key VARCHAR,
  date_value VARCHAR,
  fiscal_year VARCHAR,
  fiscal_quarter VARCHAR,
  month_name VARCHAR,
  full_date VARCHAR,
  month_key VARCHAR,
  source_file VARCHAR,
  source_row_number NUMBER,
  source_file_content_key VARCHAR,
  source_file_last_modified TIMESTAMP_NTZ,
  ingested_at TIMESTAMP_LTZ
);

CREATE TABLE IF NOT EXISTS ADVENTUREWORKS_DE.RAW.SALES_TERRITORY_RAW (
  sales_territory_key VARCHAR,
  region VARCHAR,
  country VARCHAR,
  territory_group VARCHAR,
  source_file VARCHAR,
  source_row_number NUMBER,
  source_file_content_key VARCHAR,
  source_file_last_modified TIMESTAMP_NTZ,
  ingested_at TIMESTAMP_LTZ
);
