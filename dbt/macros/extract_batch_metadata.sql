{% macro extract_batch_id(column_name) -%}
  COALESCE(
    REGEXP_SUBSTR(
      {{ column_name }},
      'batch_id=([^/]+)',
      1,
      1,
      'e',
      1
    ),
    'UNBATCHED'
  )
{%- endmacro %}

{% macro extract_batch_date(column_name) -%}
  TRY_TO_DATE(
    REGEXP_SUBSTR(
      {{ column_name }},
      'batch_date=([0-9]{4}-[0-9]{2}-[0-9]{2})',
      1,
      1,
      'e',
      1
    )
  )
{%- endmacro %}

