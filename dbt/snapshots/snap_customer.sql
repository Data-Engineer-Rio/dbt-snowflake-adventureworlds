{% snapshot snap_customer %}

{{
  config(
    target_database='ADVENTUREWORKS_DE',
    target_schema='SNAPSHOTS' if target.name == 'prod' else 'DEV_SNAPSHOTS',
    unique_key='customer_key',
    strategy='check',
    check_cols=[
      'customer_id',
      'customer_name',
      'city',
      'state_province',
      'country_region',
      'postal_code'
    ],
    hard_deletes='ignore'
  )
}}

SELECT *
FROM {{ ref('stg_customer') }}

{% endsnapshot %}
