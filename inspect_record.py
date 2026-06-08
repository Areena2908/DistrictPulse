import requests
import json

def get_record():
    url = "https://maps2.dcgis.dc.gov/dcgis/rest/services/DCGIS_DATA/ServiceRequests/FeatureServer/18/query"
    params = {
        "where": "1=1",
        "outFields": "*",
        "f": "json",
        "resultRecordCount": 1
    }
    response = requests.get(url, params=params)
    data = response.json()
    if 'features' in data and len(data['features']) > 0:
        print(json.dumps(data['features'][0]['attributes'], indent=2))
            
if __name__ == '__main__':
    get_record()
