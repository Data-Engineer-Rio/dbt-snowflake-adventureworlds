# Business definitions

| Term | Definition |
|---|---|
| Sales order line | Atomic fact grain identified by `SalesOrderLineKey`. |
| Channel | `Internet` for direct customer sales or `Reseller` for partner sales. |
| Order quantity | Number of product units on the sales order line. |
| Unit price | Source price per unit before line-level adjustments. |
| Extended amount | `Order Quantity * Unit Price`, within monetary rounding tolerance. |
| Product standard cost | Source standard unit cost captured on the sales line. |
| Total product cost | `Order Quantity * Product Standard Cost`. |
| Sales amount | Authoritative realized line sales value supplied by the source. |
| Discount amount | `Extended Amount - Sales Amount`. This includes adjustments not represented by discount percentage alone. |
| Gross profit amount | `Sales Amount - Total Product Cost`. |
| Current dimension version | SCD2 row whose `IS_CURRENT` is true. |
| Unknown member | Natural key `-1`, intentionally used when a dimension does not apply to the channel. |
| Complete batch | One batch ID containing all seven expected non-empty datasets. |

## Channel rules

```text
Internet: CustomerKey != -1 and ResellerKey = -1
Reseller: ResellerKey != -1 and CustomerKey = -1
```

## Reconciliation meaning

The UDM matches its source when all of the following pass:

- Source and fact keys cover each other.
- Row count and distinct grain count match.
- Quantity, extended amount, total cost and sales amount control totals match.
- Hashes of important business fields match at line level.
- Dimension foreign keys resolve.
- Automated format and business-rule tests pass.

