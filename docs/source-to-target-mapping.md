# Source-to-target mapping

## Fact: FCT_SALES_ORDER_LINE

| UDM field | Source field/model | Transformation |
|---|---|---|
| `sales_order_line_key` | `sales_data.SalesOrderLineKey` | `TRY_TO_NUMBER`; fact grain and merge key |
| `sales_order_number` | `sales_order_data.Sales Order` | Trim whitespace |
| `sales_order_line_label` | `sales_order_data.Sales Order Line` | Trim whitespace |
| `channel` | `sales_order_data.Channel` | Trim; accepted values Internet/Reseller |
| `customer_key` | `sales_data.CustomerKey` | Natural key; `-1` means not applicable |
| `customer_version_key` | `DIM_CUSTOMER.customer_version_key` | Current SCD2 version for `customer_key` |
| `reseller_key` | `sales_data.ResellerKey` | Natural key; `-1` means not applicable |
| `reseller_version_key` | `DIM_RESELLER.reseller_version_key` | Current SCD2 version for `reseller_key` |
| `product_key` | `sales_data.ProductKey` | Natural product key |
| `product_version_key` | `DIM_PRODUCT.product_version_key` | Current SCD2 version for `product_key` |
| `sales_territory_key` | `sales_data.SalesTerritoryKey` | Natural territory key |
| `sales_territory_version_key` | `DIM_SALES_TERRITORY.sales_territory_version_key` | Current SCD2 version for territory key |
| `order_date_key` | `sales_data.OrderDateKey` | Integer YYYYMMDD key |
| `order_date` | `date_data.Date` via OrderDateKey | `TRY_TO_DATE` |
| `due_date_key` | `sales_data.DueDateKey` | Integer YYYYMMDD key |
| `due_date` | `date_data.Date` via DueDateKey | `TRY_TO_DATE` |
| `ship_date_key` | `sales_data.ShipDateKey` | Nullable integer YYYYMMDD key |
| `ship_date` | `date_data.Date` via ShipDateKey | Nullable `TRY_TO_DATE` |
| `order_quantity` | `sales_data.Order Quantity` | `TRY_TO_NUMBER` |
| `unit_price` | `sales_data.Unit Price` | Decimal rounded to 4 places |
| `extended_amount` | `sales_data.Extended Amount` | Decimal rounded to 4 places |
| `unit_price_discount_pct` | `sales_data.Unit Price Discount Pct` | Decimal rounded to 6 places; descriptive only |
| `product_standard_cost` | `sales_data.Product Standard Cost` | Decimal rounded to 4 places |
| `total_product_cost` | `sales_data.Total Product Cost` | Decimal rounded to 4 places |
| `sales_amount` | `sales_data.Sales Amount` | Authoritative decimal rounded to 4 places |
| `discount_amount` | Derived | `extended_amount - sales_amount` |
| `gross_profit_amount` | Derived | `sales_amount - total_product_cost` |
| `batch_id` | S3 object key | Regex extracts `batch_id=<value>` |
| `sales_source_file` | Snowflake `METADATA$FILENAME` | Lineage metadata |
| `order_source_file` | Snowflake `METADATA$FILENAME` | Lineage metadata |
| `source_ingested_at` | Snowflake `METADATA$START_SCAN_TIME` | Latest timestamp across paired source rows |
| `record_hash` | Selected business fields | MD5 used for field-level reconciliation |
| `warehouse_updated_at` | Warehouse runtime | `CURRENT_TIMESTAMP()` during merge |

## DIM_CUSTOMER

| UDM field | Source field | Transformation |
|---|---|---|
| `customer_version_key` | dbt snapshot metadata | `dbt_scd_id` |
| `customer_key` | `customer_data.CustomerKey` | `TRY_TO_NUMBER` natural key |
| `customer_id` | `customer_data.Customer ID` | Trim |
| `customer_name` | `customer_data.Customer` | Trim |
| `city` | `customer_data.City` | Trim |
| `state_province` | `customer_data.State-Province` | Trim |
| `country_region` | `customer_data.Country-Region` | Trim |
| `postal_code` | `customer_data.Postal Code` | Trim; retained as string |
| `valid_from` / `valid_to` | dbt snapshot metadata | SCD2 system-observed validity |
| `is_current` | dbt snapshot metadata | `dbt_valid_to IS NULL` |

## DIM_RESELLER

| UDM field | Source field | Transformation |
|---|---|---|
| `reseller_version_key` | dbt snapshot metadata | `dbt_scd_id` |
| `reseller_key` | `reseller_data.ResellerKey` | `TRY_TO_NUMBER` natural key |
| `reseller_id` | `reseller_data.Reseller ID` | Trim |
| `business_type` | `reseller_data.Business Type` | Trim |
| `reseller_name` | `reseller_data.Reseller` | Trim |
| `city`, `state_province`, `country_region`, `postal_code` | Corresponding source fields | Trim; postal code stays string |
| `valid_from` / `valid_to` / `is_current` | dbt snapshot metadata | SCD2 system-observed history |

## DIM_PRODUCT

| UDM field | Source field | Transformation |
|---|---|---|
| `product_version_key` | dbt snapshot metadata | `dbt_scd_id` |
| `product_key` | `product_data.ProductKey` | `TRY_TO_NUMBER` natural key |
| `sku` | `product_data.SKU` | Trim |
| `product_name` | `product_data.Product` | Trim |
| `standard_cost` | `product_data.Standard Cost` | Decimal rounded to 4 places |
| `color`, `model`, `subcategory`, `category` | Corresponding source fields | Trim |
| `list_price` | `product_data.List Price` | Decimal rounded to 4 places |
| `valid_from` / `valid_to` / `is_current` | dbt snapshot metadata | SCD2 system-observed history |

## DIM_SALES_TERRITORY

| UDM field | Source field | Transformation |
|---|---|---|
| `sales_territory_version_key` | dbt snapshot metadata | `dbt_scd_id` |
| `sales_territory_key` | `sales_territory_data.SalesTerritoryKey` | `TRY_TO_NUMBER` |
| `region` | `sales_territory_data.Region` | Trim |
| `country` | `sales_territory_data.Country` | Trim |
| `territory_group` | `sales_territory_data.Group` | Trim |
| `valid_from` / `valid_to` / `is_current` | dbt snapshot metadata | SCD2 system-observed history |

## DIM_DATE

| UDM field | Source field | Transformation |
|---|---|---|
| `date_key` | `date_data.DateKey` | `TRY_TO_NUMBER` |
| `date_value` | `date_data.Date` | `TRY_TO_DATE` |
| `fiscal_year` | `date_data.Fiscal Year` | Trim |
| `fiscal_quarter` | `date_data.Fiscal Quarter` | Trim |
| `month_name` | `date_data.Month` | Trim |
| `month_key` | `date_data.MonthKey` | `TRY_TO_NUMBER` |
| `full_date_label` | `date_data.Full Date` | Retained display label |
| Calendar attributes | `date_value` | Snowflake date functions |

