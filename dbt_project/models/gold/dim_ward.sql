{{ config(materialized='table') }}

SELECT DISTINCT
    ward
FROM {{ ref('silver_service_requests') }}
WHERE ward IS NOT NULL
