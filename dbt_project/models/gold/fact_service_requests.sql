{{ config(materialized='table') }}

SELECT
    servicerequestid,
    ward,
    service_type,
    agency,
    status,
    priority,
    created_at,
    closed_at,
    due_at,
    resolution_days,
    sla_breached,
    latitude,
    longitude
FROM {{ ref('silver_service_requests') }}
