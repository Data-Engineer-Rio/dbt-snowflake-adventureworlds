SELECT *
FROM {{ ref('audit_reconciliation_summary') }}
WHERE status = 'FAIL'

