# AI usage log

This file is intentionally maintained in source control to satisfy the project requirement to document responsible AI assistance.

| Date | Activity | Human verification |
|---|---|---|
| 2026-08-31 | Generated initial architecture, Snowflake DDL, dbt models and test candidates. | Source headers, row counts, key coverage and control totals were profiled against the supplied workbook export. |
| 2026-08-31 | Identified a mismatch between sales amount and the published discount-percentage formula. | Verified 3,282 source records fail the formula; the test was intentionally excluded and documented. |
| 2026-08-31 | Drafted Snowflake Native CI/CD using GitHub OIDC. | Compared commands and privilege model with official Snowflake documentation. |

AI-generated changes must receive normal code review, CI validation and production reconciliation. AI output is not treated as evidence of data correctness.

