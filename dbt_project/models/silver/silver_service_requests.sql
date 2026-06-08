{{ config(materialized='view') }}

WITH base AS (
    SELECT
        -- Request ID (using servicerequestid for deduplication)
        servicerequestid,
        
        -- Categorical columns
        COALESCE(servicecodedescription, 'Unknown') AS service_type,
        COALESCE(servicetypecodedescription, 'Unknown') AS service_category,
        COALESCE(organizationacronym, 'Unknown') AS agency,
        COALESCE(serviceorderstatus, 'Unknown') AS status,
        COALESCE(priority, 'Standard') AS priority,
        
        -- Standardize WARD
        CASE 
            WHEN ward IS NULL OR ward = '' OR ward = 'Null' THEN 'Unknown Ward'
            WHEN ward LIKE 'Ward %' THEN ward
            WHEN CAST(ward AS VARCHAR) IN ('1','2','3','4','5','6','7','8') THEN 'Ward ' || ward
            ELSE 'Unknown Ward'
        END AS ward,
        
        -- Location
        latitude,
        longitude,
        streetaddress AS address,
        
        -- Dates (Converting from epoch ms to timestamp)
        epoch_ms(CAST(serviceorderdate AS BIGINT)) AS created_at,
        epoch_ms(CAST(resolutiondate AS BIGINT)) AS closed_at,
        epoch_ms(CAST(serviceduedate AS BIGINT)) AS due_at,
        
        -- Metadata from Bronze
        _source_file,
        _loaded_at,
        
        -- Add row number for deduplication by servicerequestid
        ROW_NUMBER() OVER(PARTITION BY servicerequestid ORDER BY serviceorderdate DESC) AS rn
    FROM {{ ref('bronze_service_requests') }}
    WHERE servicerequestid IS NOT NULL
),

cleaned AS (
    SELECT 
        * EXCLUDE(rn)
    FROM base
    WHERE rn = 1
),

calculated AS (
    SELECT
        *,
        -- Calculate resolution days
        CASE 
            WHEN closed_at IS NOT NULL AND created_at IS NOT NULL 
            THEN EXTRACT('epoch' FROM (closed_at - created_at)) / 86400.0 
            ELSE NULL 
        END AS resolution_days,
        
        -- Calculate SLA breached boolean
        CASE 
            WHEN closed_at IS NOT NULL AND due_at IS NOT NULL 
            THEN closed_at > due_at 
            ELSE FALSE 
        END AS sla_breached
    FROM cleaned
    -- Filter out impossible records (closed before created)
    WHERE (closed_at IS NULL OR closed_at >= created_at)
)

SELECT * FROM calculated
