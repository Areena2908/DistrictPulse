import requests
import json

def get_schema():
    url = "https://maps2.dcgis.dc.gov/dcgis/rest/services/DCGIS_DATA/ServiceRequests/FeatureServer/18/query"
    params = {
        "where": "1=1",
        "outFields": "*",
        "f": "json",
        "resultRecordCount": 1
    }
    response = requests.get(url, params=params)
    data = response.json()
    if 'fields' in data:
        for f in data['fields']:
            print(f"{f['name']}: {f['type']}")
            
if __name__ == '__main__':
    get_schema()
