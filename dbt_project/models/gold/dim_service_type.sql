{{ config(materialized='table') }}

SELECT DISTINCT
    service_type,
    MAX(service_category) AS service_category
FROM {{ ref('silver_service_requests') }}
WHERE service_type IS NOT NULL
GROUP BY service_type
