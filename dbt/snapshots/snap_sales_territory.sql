{% snapshot snap_sales_territory %}

{{
  config(
    target_database='ADVENTUREWORKS_DE',
    target_schema='SNAPSHOTS' if target.name == 'prod' else 'DEV_SNAPSHOTS',
    unique_key='sales_territory_key',
    strategy='check',
    check_cols=[
      'region',
      'country',
      'territory_group'
    ],
    hard_deletes='ignore'
  )
}}

SELECT *
FROM {{ ref('stg_sales_territory') }}

{% endsnapshot %}
