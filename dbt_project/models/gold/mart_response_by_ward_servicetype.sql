{{ config(materialized='table') }}

SELECT
    ward,
    service_type,
    COUNT(*) AS total_requests,
    median(resolution_days) AS median_resolution_days
FROM {{ ref('fact_service_requests') }}
WHERE status = 'Closed'
GROUP BY ward, service_type
