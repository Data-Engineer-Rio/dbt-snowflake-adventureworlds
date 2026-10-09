# AdventureWorks Sales Data Platform

Production-oriented reference implementation for the mock-project requirements:

```text
AWS S3 immutable batch files
  -> Snowflake storage integration and external stage
  -> Snowpipe auto-ingest
  -> append-only RAW tables
  -> dbt staging and batch-completeness gate
  -> dbt snapshots for SCD Type 2 history
  -> analytical dimensions and FCT_SALES_ORDER_LINE
  -> automated tests and reconciliation
  -> GitHub Actions CI/CD using Snowflake OIDC
```

## Source contract

Every delivery must contain all seven CSV files under one immutable batch path:

```text
s3://<bucket>/adventureworks/
  batch_date=YYYY-MM-DD/
  batch_id=YYYYMMDDTHH24MISSZ/
    sales_data.csv
    sales_order_data.csv
    customer_data.csv
    reseller_data.csv
    product_data.csv
    date_data.csv
    sales_territory_data.csv
```

The current source has no CDC operation or reliable update timestamp. Therefore each delivery is treated as a full source snapshot. Snowpipe loads each new file once; dbt selects the latest complete batch and detects dimensional changes.

Missing records are not inferred as deletes. Snapshot hard-delete handling remains `ignore` until the source owner defines deletion semantics.

Never overwrite a previously loaded S3 object. Use a new `batch_id` for every delivery.

## Repository layout

```text
aws/                    AWS IAM and S3 event-notification templates
snowflake/              One-time setup, RAW DDL, Snowpipes, gates and Tasks
dbt/                    dbt Project for Snowflake Native
.github/workflows/      Pull Request CI and production CD
docs/                   Runbooks, mapping and business definitions
scripts/                Local static validation helpers
```

## Deployment order

1. Replace placeholders in `aws/` and configure the IAM policy and IAM role.
2. Run `snowflake/00_bootstrap/001_bootstrap.sql` as an administrator.
3. Run `snowflake/01_storage/010_storage_integration.sql`, update the AWS trust policy, then validate the integration.
4. Run `snowflake/01_storage/011_stage_and_file_format.sql` as `AW_INGEST_ROLE`.
5. Select `AW_INGEST_ROLE`, then run `snowflake/02_raw/020_create_raw_tables.sql`.
6. Run `snowflake/03_ingestion/030_create_pipes.sql`.
7. Configure the S3 event notification using `docs/operations-runbook.md`.
8. Upload a new complete batch and verify all seven RAW tables.
9. Deploy the dbt project:

```bash
snow dbt deploy AW_ANALYTICS \
  --source ./dbt \
  --default-target prod \
  --dbt-version 1.11.11 \
  --connection aw-prod

snow dbt execute --connection aw-prod \
  AW_ANALYTICS build --target prod
```

10. Run `snowflake/05_reconciliation/050_prod_gate.sql`.
11. Run `snowflake/06_orchestration/060_dbt_tasks.sql` only after the production build passes.

## Initial expected reconciliation

For the supplied workbook export:

| Metric | Expected |
|---|---:|
| Fact rows | 121,253 |
| Distinct sales order line keys | 121,253 |
| Order quantity | 274,776 |
| Sales amount | 109,809,274.2030 |

These values are an initial-load baseline, not permanent constants for future batches.

## Important business caveat

`Sales Amount` is authoritative. The formula below fails for 3,282 supplied records and is intentionally not a blocking test:

```text
Sales Amount = Extended Amount * (1 - Unit Price Discount Pct)
```

The project derives `discount_amount = extended_amount - sales_amount` until the source owner provides the missing discount/adjustment semantics.

## Local validation

The repository does not require local dbt Core for production execution. If Snowflake CLI is installed and a connection is configured:

```bash
./scripts/validate_project.sh
snow dbt deploy AW_ANALYTICS_DEV --source ./dbt --default-target dev --connection aw-dev
snow dbt execute --connection aw-dev AW_ANALYTICS_DEV build --target dev
```

See `docs/operations-runbook.md` for setup, monitoring, backfill and recovery procedures.
