#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

python3 "${project_root}/scripts/static_validate.py"

if command -v dbt >/dev/null 2>&1; then
  (
    cd "${project_root}/dbt"
    dbt parse --no-partial-parse
  )
else
  echo "dbt is not installed locally; skipped dbt parse. Snowflake Native CI runs the build."
fi

