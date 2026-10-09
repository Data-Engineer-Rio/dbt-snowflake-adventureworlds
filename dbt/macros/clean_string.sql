{% macro clean_string(column_name) -%}
  NULLIF(TRIM({{ column_name }}), '')
{%- endmacro %}

