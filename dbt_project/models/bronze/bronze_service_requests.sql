{{ config(materialized='view') }}

WITH raw_data AS (
    SELECT 
        *,
        filename AS _source_file,
        CURRENT_TIMESTAMP AS _loaded_at
    FROM read_csv_auto('../raw/service_requests_*.csv', filename=true)
)

SELECT * FROM raw_data
