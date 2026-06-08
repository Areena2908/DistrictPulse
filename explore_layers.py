import requests

def list_layers():
    url = "https://maps2.dcgis.dc.gov/dcgis/rest/services/DCGIS_DATA/ServiceRequests/FeatureServer?f=json"
    response = requests.get(url)
    data = response.json()
    for layer in data.get('layers', []):
        print(f"Layer ID: {layer['id']}, Name: {layer['name']}")

if __name__ == '__main__':
    list_layers()
