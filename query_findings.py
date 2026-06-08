import duckdb

conn = duckdb.connect('dc_311.duckdb')

print("--- Overall SLA Breach Rate ---")
print(conn.execute("""
    SELECT 
        SUM(breached_requests) / SUM(closed_requests) AS overall_breach_rate 
    FROM mart_sla_by_ward 
    WHERE closed_requests > 0
""").fetchdf())

print("\n--- Median Resolution Days by Ward ---")
print(conn.execute("""
    SELECT ward, median_resolution_days 
    FROM mart_sla_by_ward 
    ORDER BY median_resolution_days DESC
""").fetchdf())

print("\n--- Disparity for a common service type (e.g. Bulk Collection) ---")
print(conn.execute("""
    SELECT service_type, ward, median_resolution_days
    FROM mart_response_by_ward_servicetype
    WHERE service_type = 'Bulk Collection'
    ORDER BY median_resolution_days DESC
""").fetchdf())

print("\n--- Busiest Month ---")
print(conn.execute("""
    SELECT created_month, SUM(request_volume) as total_vol
    FROM mart_volume_trend
    GROUP BY created_month
    ORDER BY total_vol DESC
    LIMIT 3
""").fetchdf())
