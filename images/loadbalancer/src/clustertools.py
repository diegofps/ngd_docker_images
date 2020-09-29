from subprocess import Popen, PIPE, TimeoutExpired
from utils import debug

import traceback
import requests
import params
import shlex
import json
import sys


def get_stats(node_ip):
    return get_stats_using_telemetry(node_ip)


def get_stats_using_telemetry(node_ip):
    j = requests.get("http://" + node_ip + ":4580").json()
    return j["name"], j["idle"], j["busy"], j["arch"], j["cpus"]
