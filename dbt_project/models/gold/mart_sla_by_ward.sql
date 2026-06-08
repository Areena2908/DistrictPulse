{{ config(materialized='table') }}

SELECT
    ward,
    COUNT(*) AS total_requests,
    COUNT(CASE WHEN status = 'Closed' THEN 1 END) AS closed_requests,
    COUNT(CASE WHEN status = 'Closed' AND sla_breached THEN 1 END) AS breached_requests,
    
    -- breach rate = breached / closed
    CASE 
        WHEN COUNT(CASE WHEN status = 'Closed' THEN 1 END) > 0 
        THEN CAST(COUNT(CASE WHEN status = 'Closed' AND sla_breached THEN 1 END) AS DOUBLE) / COUNT(CASE WHEN status = 'Closed' THEN 1 END)
        ELSE 0 
    END AS breach_rate,
    
    -- duckdb median aggregate
    median(resolution_days) AS median_resolution_days,
    
    -- backlog = open requests past due date
    COUNT(CASE WHEN status IN ('Open', 'In-Progress') AND CURRENT_TIMESTAMP > due_at THEN 1 END) AS open_backlog

FROM {{ ref('fact_service_requests') }}
GROUP BY ward
