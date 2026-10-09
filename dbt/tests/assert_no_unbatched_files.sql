SELECT *
FROM {{ ref('int_batch_file_inventory') }}
WHERE batch_id = 'UNBATCHED'
   OR batch_date IS NULL
