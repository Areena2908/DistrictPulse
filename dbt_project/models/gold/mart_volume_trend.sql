{{ config(materialized='table') }}

SELECT
    date_trunc('month', created_at) AS created_month,
    ward,
    COUNT(*) AS request_volume
FROM {{ ref('fact_service_requests') }}
WHERE created_at IS NOT NULL
GROUP BY date_trunc('month', created_at), ward
ORDER BY created_month, ward
