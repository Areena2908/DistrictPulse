import requests
import pandas as pd
import os
import time

def ingest_layer(year, layer_id, batch_size=2000, max_records=None):
    base_url = f"https://maps2.dcgis.dc.gov/dcgis/rest/services/DCGIS_DATA/ServiceRequests/FeatureServer/{layer_id}/query"
    offset = 0
    all_features = []
    
    print(f"Starting ingestion for year {year} (Layer {layer_id})...")
    
    while True:
        params = {
            "where": "1=1",
            "outFields": "*",
            "f": "json",
            "resultOffset": offset,
            "resultRecordCount": batch_size
        }
        
        try:
            response = requests.get(base_url, params=params)
            response.raise_for_status()
            data = response.json()
            
            features = data.get("features", [])
            if not features:
                break
                
            # Extract attributes from each feature
            records = [f.get("attributes", {}) for f in features]
            all_features.extend(records)
            
            offset += batch_size
            print(f"Year {year}: Fetched {len(all_features)} records...", end='\r')
            
            if max_records and len(all_features) >= max_records:
                all_features = all_features[:max_records]
                break
                
            # Be nice to the API
            time.sleep(0.1)
            
        except Exception as e:
            print(f"\nError fetching data for year {year} at offset {offset}: {e}")
            break

    print(f"\nFinished year {year}: Total {len(all_features)} records fetched.")
    
    if all_features:
        df = pd.DataFrame(all_features)
        # Clean column names (lowercase them for DuckDB/dbt convenience)
        df.columns = [col.lower() for col in df.columns]
        
        output_file = f"raw/service_requests_{year}.csv"
        df.to_csv(output_file, index=False)
        print(f"Saved to {output_file}")

if __name__ == "__main__":
    os.makedirs("raw", exist_ok=True)
    
    layers = {
        2022: 14,
        2023: 15,
        2024: 16,
        2025: 18
    }
    
    # We will fetch a subset for the portfolio project if requested, or the full set.
    # To avoid API timeouts and huge disk usage in this environment, let's fetch full data.
    # Warning: 4 years of data may take a while.
    for year, layer_id in layers.items():
        # Using a limit for the environment safety initially, but in reality we'd pull all.
        # Actually the spec asks for >1M rows total. Let's pull up to 300,000 per year.
        ingest_layer(year, layer_id, max_records=300000)
    
    print("Ingestion complete.")
