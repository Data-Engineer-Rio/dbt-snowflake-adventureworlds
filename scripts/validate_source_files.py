#!/usr/bin/env python3
"""Validate the seven AdventureWorks CSV files before publishing them to S3."""

from __future__ import annotations

import argparse
import csv
from decimal import Decimal
from pathlib import Path


EXPECTED_HEADERS = {
    "sales_data.csv": [
        "SalesOrderLineKey", "ResellerKey", "CustomerKey", "ProductKey",
        "OrderDateKey", "DueDateKey", "ShipDateKey", "SalesTerritoryKey",
        "Order Quantity", "Unit Price", "Extended Amount",
        "Unit Price Discount Pct", "Product Standard Cost",
        "Total Product Cost", "Sales Amount",
    ],
    "sales_order_data.csv": [
        "Channel", "SalesOrderLineKey", "Sales Order", "Sales Order Line",
    ],
    "customer_data.csv": [
        "CustomerKey", "Customer ID", "Customer", "City", "State-Province",
        "Country-Region", "Postal Code",
    ],
    "reseller_data.csv": [
        "ResellerKey", "Reseller ID", "Business Type", "Reseller", "City",
        "State-Province", "Country-Region", "Postal Code",
    ],
    "product_data.csv": [
        "ProductKey", "SKU", "Product", "Standard Cost", "Color", "List Price",
        "Model", "Subcategory", "Category",
    ],
    "date_data.csv": [
        "DateKey", "Date", "Fiscal Year", "Fiscal Quarter", "Month", "Full Date",
        "MonthKey",
    ],
    "sales_territory_data.csv": [
        "SalesTerritoryKey", "Region", "Country", "Group",
    ],
}


def read_rows(path: Path) -> list[dict[str, str]]:
    with path.open(newline="", encoding="utf-8-sig") as stream:
        reader = csv.DictReader(stream)
        if reader.fieldnames != EXPECTED_HEADERS[path.name]:
            raise ValueError(
                f"{path.name}: unexpected header\n"
                f"expected={EXPECTED_HEADERS[path.name]}\nactual={reader.fieldnames}"
            )
        rows = list(reader)
    if not rows:
        raise ValueError(f"{path.name}: file contains no data rows")
    return rows


def assert_unique(rows: list[dict[str, str]], key: str, filename: str) -> None:
    values = [row[key] for row in rows]
    if any(value == "" for value in values):
        raise ValueError(f"{filename}: blank {key}")
    if len(values) != len(set(values)):
        raise ValueError(f"{filename}: duplicate {key}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("csv_dir", type=Path)
    args = parser.parse_args()

    missing = [name for name in EXPECTED_HEADERS if not (args.csv_dir / name).is_file()]
    if missing:
        raise SystemExit(f"Missing required files: {', '.join(missing)}")

    data = {name: read_rows(args.csv_dir / name) for name in EXPECTED_HEADERS}

    assert_unique(data["sales_data.csv"], "SalesOrderLineKey", "sales_data.csv")
    assert_unique(
        data["sales_order_data.csv"], "SalesOrderLineKey", "sales_order_data.csv"
    )
    assert_unique(data["customer_data.csv"], "CustomerKey", "customer_data.csv")
    assert_unique(data["reseller_data.csv"], "ResellerKey", "reseller_data.csv")
    assert_unique(data["product_data.csv"], "ProductKey", "product_data.csv")
    assert_unique(data["date_data.csv"], "DateKey", "date_data.csv")
    assert_unique(
        data["sales_territory_data.csv"],
        "SalesTerritoryKey",
        "sales_territory_data.csv",
    )

    sales = data["sales_data.csv"]
    orders = data["sales_order_data.csv"]
    sales_keys = {row["SalesOrderLineKey"] for row in sales}
    order_keys = {row["SalesOrderLineKey"] for row in orders}
    if sales_keys != order_keys:
        raise ValueError("Sales and Sales Order keys do not cover each other")

    dimension_keys = {
        "CustomerKey": {row["CustomerKey"] for row in data["customer_data.csv"]},
        "ResellerKey": {row["ResellerKey"] for row in data["reseller_data.csv"]},
        "ProductKey": {row["ProductKey"] for row in data["product_data.csv"]},
        "SalesTerritoryKey": {
            row["SalesTerritoryKey"]
            for row in data["sales_territory_data.csv"]
        },
    }
    date_keys = {row["DateKey"] for row in data["date_data.csv"]}
    channel_by_line = {
        row["SalesOrderLineKey"]: row["Channel"] for row in orders
    }
    tolerance = Decimal("0.01")

    for row in sales:
        line_key = row["SalesOrderLineKey"]
        for field, valid_values in dimension_keys.items():
            if row[field] not in valid_values:
                raise ValueError(f"Sales line {line_key}: orphan {field}={row[field]}")
        for field in ("OrderDateKey", "DueDateKey"):
            if row[field] not in date_keys:
                raise ValueError(f"Sales line {line_key}: orphan {field}={row[field]}")
        if row["ShipDateKey"] and row["ShipDateKey"] not in date_keys:
            raise ValueError(
                f"Sales line {line_key}: orphan ShipDateKey={row['ShipDateKey']}"
            )

        quantity_value = Decimal(row["Order Quantity"])
        unit_price = Decimal(row["Unit Price"])
        extended = Decimal(row["Extended Amount"])
        standard_cost = Decimal(row["Product Standard Cost"])
        total_cost = Decimal(row["Total Product Cost"])
        sales_value = Decimal(row["Sales Amount"])
        if abs(extended - quantity_value * unit_price) > tolerance:
            raise ValueError(f"Sales line {line_key}: invalid extended amount")
        if abs(total_cost - quantity_value * standard_cost) > tolerance:
            raise ValueError(f"Sales line {line_key}: invalid total product cost")
        if sales_value < 0 or sales_value > extended + tolerance:
            raise ValueError(f"Sales line {line_key}: invalid sales amount range")

        channel = channel_by_line[line_key]
        if channel == "Internet" and (
            row["CustomerKey"] == "-1" or row["ResellerKey"] != "-1"
        ):
            raise ValueError(f"Sales line {line_key}: invalid Internet dimension keys")
        if channel == "Reseller" and (
            row["ResellerKey"] == "-1" or row["CustomerKey"] != "-1"
        ):
            raise ValueError(f"Sales line {line_key}: invalid Reseller dimension keys")

    quantity = sum(int(row["Order Quantity"]) for row in sales)
    sales_amount = sum(Decimal(row["Sales Amount"]) for row in sales)

    print("Source validation passed")
    for name, rows in data.items():
        print(f"{name}: {len(rows):,} rows")
    print(f"order_quantity: {quantity:,}")
    print(f"sales_amount: {sales_amount.quantize(Decimal('0.0001')):,}")


if __name__ == "__main__":
    main()
