# Operations runbook

## 1. One-time AWS and Snowflake setup

1. Create the S3 IAM permission policy from `aws/iam/s3-read-policy.json.template`.
2. Create an IAM role with a temporary trust relationship and attach the policy.
3. Replace placeholders and run `snowflake/01_storage/010_storage_integration.sql.template`.
4. Copy `STORAGE_AWS_IAM_USER_ARN` and `STORAGE_AWS_EXTERNAL_ID` from `DESC INTEGRATION`.
5. Update the IAM role trust policy using `aws/iam/trust-policy.json.template`.
6. Run `SYSTEM$VALIDATE_STORAGE_INTEGRATION`; status must be `success`.
7. Create the external stage and verify `LIST @ADVENTUREWORKS_DE.LANDING.AW_S3_STAGE`.

## 2. Configure automatic S3 notification

After all pipes exist:

```sql
SHOW PIPES IN SCHEMA ADVENTUREWORKS_DE.LANDING;

SELECT DISTINCT "notification_channel"
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE "notification_channel" IS NOT NULL;
```

In AWS S3 bucket properties, create one event notification:

| Setting | Value |
|---|---|
| Event | All object create events |
| Prefix | `adventureworks/` |
| Suffix | `.csv` |
| Destination | SQS queue ARN from `notification_channel` |

One common notification can service all seven pipes. Each pipe filters its own filename.

## 3. Validate a new batch

Upload all seven files to one new immutable path. Do not overwrite old keys.

Run:

```sql
SELECT SYSTEM$PIPE_STATUS('ADVENTUREWORKS_DE.LANDING.SALES_PIPE');

SELECT
  table_name,
  file_name,
  status,
  row_count,
  first_error_message,
  last_load_time
FROM SNOWFLAKE.ACCOUNT_USAGE.COPY_HISTORY
WHERE table_catalog_name = 'ADVENTUREWORKS_DE'
  AND table_schema_name = 'RAW'
ORDER BY last_load_time DESC;
```

Then execute the dbt project. `INT_LATEST_COMPLETE_BATCH` deliberately fails if the latest observed batch has fewer than seven non-empty datasets.

## 4. Existing files and backfill

- Use `031_refresh_existing_files.sql` only for recent files that predate event-notification setup.
- For large or old history, use controlled bulk `COPY INTO`, record the cutover batch, and enable Snowpipe only for new object keys.
- Do not point active Snowpipe and uncontrolled bulk COPY at the same files.

## 5. Monitoring

Monitor:

- S3 arrival SLA and seven-file batch completeness.
- `SYSTEM$PIPE_STATUS` execution state and outstanding messages.
- `COPY_HISTORY` load errors.
- dbt project execution and test results.
- `AUDIT_RECONCILIATION_SUMMARY` status.
- Task history and warehouse credit usage.

Suggested incidents:

| Severity | Examples |
|---|---|
| P1 | Financial reconciliation failure, duplicate fact key, partial batch published |
| P2 | Snowpipe failure, stale source, dbt build failure, orphan key |
| P3 | Performance regression, warning freshness threshold, documentation gap |

## 6. Recovery

### Pipe does not receive events

Check S3 prefix/suffix, event type, SQS ARN, conflicting notifications and `PATTERN`.

### Stage returns access denied

Check S3 permissions, IAM trust principal, external ID, allowed location and KMS key policy.

### dbt fails on batch completeness

Do not bypass the gate. Publish a corrected **complete batch under a new batch ID**. A batch is valid only when it contains exactly one non-empty file for each of the seven datasets.

### Code rollback

Revert the bad Git commit, merge through Pull Request, redeploy, run `dbt build`, then reconciliation. A code rollback does not automatically undo data mutations; use Time Travel, a zero-copy clone or a forward fix when data recovery is required.

## 7. Known source limitations

- No operation type, change sequence or reliable `updated_at`; true CDC is unavailable.
- History starts at platform go-live; earlier versions cannot be reconstructed from one snapshot.
- A disappearance from a full file is not automatically treated as a fact or dimension delete until the source owner confirms the delete contract. Snapshots therefore use `hard_deletes='ignore'`.
- `Sales Amount` cannot be reconstructed from `Unit Price Discount Pct` for all supplied records.
