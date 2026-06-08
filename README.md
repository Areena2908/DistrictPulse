# DC 311 Service Analytics Platform

**One-line pitch:** An end-to-end analytics platform that ingests DC's 311 service-request data from a live government API, models it in a layered SQL warehouse, and surfaces metrics exposing service-response disparities across city wards.

## Overview
This project extracts 311 service request data for Washington DC directly from the ArcGIS REST API for the years 2022-2025. It uses a modern data stack (Python, DuckDB, dbt) to clean, standardize, and transform the data into a Gold layer optimized for Business Intelligence reporting.

## Architecture
```
DC Open Data API
        │
        ▼
[ Python Ingestion (ingest.py) ] ──► raw/ (CSV files)
        │
        ▼
┌─────────────────────────────────────────────┐
│              dbt + DuckDB                     │
│                                               │
│  BRONZE  Raw load, 1:1                        │
│     ▼                                         │
│  SILVER  Cleaned dates, deduped, wards        │
│     ▼                                         │
│  GOLD    fact_service_requests, dim_ward,     │
│          mart_sla_by_ward, etc.               │
└─────────────────────────────────────────────┘
        │
        ▼
Power BI / BI Tools (Connected to duckdb or CSVs)
```

## Setup & Run Instructions

1. **Install Dependencies**
   ```bash
   python -m venv .venv
   source .venv/bin/activate
   pip install requests pandas duckdb dbt-duckdb
   ```

2. **Ingest Data**
   Run the ingestion script to pull data from the API into the `raw/` folder.
   ```bash
   python ingest.py
   ```

3. **Run Transformations**
   Navigate to the dbt project and run the models:
   ```bash
   cd dbt_project
   dbt run --profiles-dir .
   dbt test --profiles-dir .
   ```

4. **Connect to Power BI**
   - Open Power BI Desktop.
   - Use the **ODBC** connector to connect to `dc_311.duckdb` (requires DuckDB ODBC driver), OR
   - You can export the gold tables to CSV using DuckDB CLI (`COPY mart_sla_by_ward TO 'mart_sla_by_ward.csv' (HEADER, DELIMITER ',');`) and load them directly into Power BI to build the Dashboard as per the specification.

## Executive Brief
*Note: Run the final dbt models and query the mart tables to see the final numeric outputs. The metrics below represent the structure of the analysis findings.*

**Key Findings:**
1. **Response Equity Gap:** Ward X waits a median of N days longer than Ward Y for critical services like bulk collection.
2. **SLA Breach Rate:** Across all wards, approximately Z% of service requests are not fulfilled within their target due date.
3. **Volume Trend:** The total volume of requests peaks during the summer months, putting additional strain on specific agencies.

**Recommendation:**
Deploy additional operational resources to the wards experiencing the highest median resolution days for standard service types to ensure equitable service delivery across the District.

## Data Dictionary (Gold Layer)
- `fact_service_requests`: The core grain table with 1 row per unique service request.
- `mart_sla_by_ward`: Aggregated SLA breach rate, median resolution days, and backlog per ward.
- `mart_response_by_ward_servicetype`: Cross-tab data showing median resolution days by ward and service type.
- `mart_volume_trend`: Monthly volume of service requests grouped by ward.

*Data sourced from DC Open Data / Office of Unified Communications. Licensed CC BY 4.0.*
