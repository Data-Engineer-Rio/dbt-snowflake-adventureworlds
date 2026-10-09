{% snapshot snap_reseller %}

{{
  config(
    target_database='ADVENTUREWORKS_DE',
    target_schema='SNAPSHOTS' if target.name == 'prod' else 'DEV_SNAPSHOTS',
    unique_key='reseller_key',
    strategy='check',
    check_cols=[
      'reseller_id',
      'business_type',
      'reseller_name',
      'city',
      'state_province',
      'country_region',
      'postal_code'
    ],
    hard_deletes='ignore'
  )
}}

SELECT *
FROM {{ ref('stg_reseller') }}

{% endsnapshot %}
