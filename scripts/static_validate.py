#!/usr/bin/env python3
"""Perform dependency-free repository structure and template validation."""

from __future__ import annotations

import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]

REQUIRED_FILES = [
    "dbt/dbt_project.yml",
    "dbt/dbt_projects_profiles.yml",
    "dbt/models/staging/_sources.yml",
    "dbt/models/intermediate/int_latest_complete_batch.sql",
    "dbt/models/marts/fct_sales_order_line.sql",
    "dbt/models/audit/audit_reconciliation_summary.sql",
    "dbt/snapshots/snap_customer.sql",
    "dbt/snapshots/snap_reseller.sql",
    "dbt/snapshots/snap_product.sql",
    "dbt/snapshots/snap_sales_territory.sql",
    "snowflake/02_raw/020_create_raw_tables.sql",
    "snowflake/03_ingestion/030_create_pipes.sql",
    ".github/workflows/dbt-ci.yml",
    ".github/workflows/dbt-cd.yml",
]


def main() -> None:
    missing = [path for path in REQUIRED_FILES if not (ROOT / path).is_file()]
    if missing:
        raise SystemExit(f"Missing required project files: {missing}")

    for relative in (
        "aws/iam/s3-read-policy.json.template",
        "aws/iam/trust-policy.json.template",
    ):
        json.loads((ROOT / relative).read_text(encoding="utf-8"))

    sql_files = list(ROOT.rglob("*.sql"))
    if not sql_files:
        raise SystemExit("No SQL files found")
    for path in sql_files:
        if not path.read_text(encoding="utf-8").strip():
            raise SystemExit(f"Empty SQL file: {path.relative_to(ROOT)}")

    pipes = (ROOT / "snowflake/03_ingestion/030_create_pipes.sql").read_text()
    expected_pipes = {
        "SALES_PIPE", "SALES_ORDER_PIPE", "CUSTOMER_PIPE", "RESELLER_PIPE",
        "PRODUCT_PIPE", "DATE_PIPE", "SALES_TERRITORY_PIPE",
    }
    missing_pipes = [name for name in expected_pipes if name not in pipes]
    if missing_pipes:
        raise SystemExit(f"Missing pipe definitions: {missing_pipes}")

    model_files = list((ROOT / "dbt/models").rglob("*.sql"))
    snapshot_files = list((ROOT / "dbt/snapshots").glob("*.sql"))
    node_names = {path.stem for path in model_files + snapshot_files}
    dbt_sql_files = model_files + snapshot_files + list((ROOT / "dbt/tests").glob("*.sql"))
    referenced_nodes: set[str] = set()
    for path in dbt_sql_files:
        referenced_nodes.update(
            re.findall(r"ref\(['\"]([^'\"]+)['\"]\)", path.read_text())
        )
    unresolved = sorted(referenced_nodes - node_names)
    if unresolved:
        raise SystemExit(f"Unresolved dbt refs: {unresolved}")

    sources = (ROOT / "dbt/models/staging/_sources.yml").read_text()
    expected_sources = {
        "sales_raw", "sales_order_raw", "customer_raw", "reseller_raw",
        "product_raw", "date_raw", "sales_territory_raw",
    }
    missing_sources = [name for name in expected_sources if f"name: {name}" not in sources]
    if missing_sources:
        raise SystemExit(f"Missing dbt sources: {missing_sources}")

    print(
        f"Static validation passed: {len(sql_files)} SQL files, "
        f"{len(list(ROOT.rglob('*.yml')))} YAML files, "
        f"{len(node_names)} dbt nodes"
    )


if __name__ == "__main__":
    main()
