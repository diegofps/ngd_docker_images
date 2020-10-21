from params import API_SERVER, CLIENT_CRT, CLIENT_KEY, SERVER_CRT, APP_NAME
from models import Node

import requests
import sys

def get_nodes():
    url = API_SERVER + "/api/v1/nodes"
    r = requests.get(url, 
            cert=(CLIENT_CRT, CLIENT_KEY), 
            verify=SERVER_CRT)
    print(url)
    print(r)
    sys.stdout.flush()
    return r.json()["items"]


def get_pods():
    url = API_SERVER + "/api/v1/pods?labelSelector=app=" + APP_NAME
    r = requests.get(url, 
            cert=(CLIENT_CRT, CLIENT_KEY), 
            verify=SERVER_CRT)
    
    return r.json()["items"]

