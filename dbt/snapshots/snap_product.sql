{% snapshot snap_product %}

{{
  config(
    target_database='ADVENTUREWORKS_DE',
    target_schema='SNAPSHOTS' if target.name == 'prod' else 'DEV_SNAPSHOTS',
    unique_key='product_key',
    strategy='check',
    check_cols=[
      'sku',
      'product_name',
      'standard_cost',
      'color',
      'list_price',
      'model',
      'subcategory',
      'category'
    ],
    hard_deletes='ignore'
  )
}}

SELECT *
FROM {{ ref('stg_product') }}

{% endsnapshot %}
