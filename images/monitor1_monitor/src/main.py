#!/usr/bin/env python3

from pymongo import MongoClient, ASCENDING, DESCENDING
from pyfacedetectioncnn import FaceDetectionCNN

import pyinotify
import traceback
import openalpr
import datetime
import asyncio
import socket
import base64
import json
import pika
import uuid
import time
import sys
import cv2
import os


HOSTHOSTNAME = os.getenv("HOSTHOSTNAME", "Unknown")
HOSTTARGET = os.getenv("HOSTTARGET", "/")
TARGET = os.getenv('TARGET', '/target')
MONGOSERVER = os.getenv('MONGOSERVER', '192.168.1.138')
MONGOUSER = os.getenv('MONGOUSER', 'mongoadmin')
MONGOPASS = os.getenv('MONGOPASS', 'secret')
MONGOPORT = int(os.getenv('MONGOPORT', '27017'))
RABBITMQSERVER = os.getenv('RABBITMQSERVER', '192.168.1.138')

print("--- PARAMS ---")
print("RABBITMQSERVER:", RABBITMQSERVER)
print("MONGOSERVER:", MONGOSERVER)

print("Starting FaceDetectionCNN")
fc = FaceDetectionCNN()

print("Starting alpr")
alpr = openalpr.Alpr("us", "/etc/openalpr/openalpr.conf", "/usr/share/openalpr/runtime_data")

if not alpr.is_loaded():
    print("Error loading OpenALPR")
    sys.exit(1)

alpr.set_top_n(20)
alpr.set_default_region("md")

print("Starting pika")
while True:
    try:
        connection = pika.BlockingConnection(pika.ConnectionParameters(RABBITMQSERVER))
        channel = connection.channel()
        channel.queue_declare(queue='hello')
        break
    except:
        print("Failed to connect to RabbitMQ, retrying in 5s")
        time.sleep(5)

print("Starting MongoClient")
cliente = MongoClient(MONGOSERVER, port=MONGOPORT, username=MONGOUSER, password=MONGOPASS)
banco = cliente['monitor-database']
album = banco['events']


def human_time(value):
    value = float(value * 1000 * 1000)
    if value < 1000:
        return "{:.2f} us".format(value)
    
    value /= 1000
    if value < 1000:
        return "{:.2f} ms".format(value)

    value /= 1000
    if value < 60:
        return "{:.2f} s".format(value)

    value /= 60
    if value < 60:
        return "{:.2f} m".format(value)

    value /= 60
    if value < 24:
        return "{:.2f} h".format(value)
    
    value /= 24
    return "{:.2f} d".format(value)

def reconnect_rabbitmq():
    global connection
    global channel

    connection = pika.BlockingConnection(pika.ConnectionParameters(RABBITMQSERVER))
    channel = connection.channel()
    channel.queue_declare(queue='hello')


def encode_image(img, max_size):
    r,c = img.shape[:2]
    factor = max_size / float(r) if r < c else max_size / float(c)
    img = cv2.resize(img, (0, 0), fx=factor, fy=factor)
    success, buffer = cv2.imencode(".jpg", img)

    if not success:
        print("Something bad happened during image encoding")
        return ''
    
    return str(base64.b64encode(bytes(buffer)), 'utf-8')


def get_plate_coords(data, key):
    v1, v2 = None, None

    for obj in data['coordinates']:
        v = obj[key]

        if v1 is None:
            v1 = v
            v2 = v
            continue
    
        if v < v1:
            v1 = v
        
        if v > v2:
            v2 = v

    return v1, v2


def prepare_response(img, pathname, ellapsed, faces, plates):
    faces2 = []
    plates2 = []

    for data in faces:
        c = data['confidence']
        r = data['rect']
        p1 = data['p1']
        p2 = data['p2']
        p3 = data['p3']
        p4 = data['p4']
        p5 = data['p5']
        
        img2 = img[r[1]:r[1]+r[3], r[0]:r[0]+r[2]]

        faces2.append({
                'uuid': str(uuid.uuid4()),
                'rect': r,
                'confidence': c,
                'p1': p1,
                'p2': p2,
                'p3': p3,
                'p4': p4,
                'p5': p5,
                'b64image': encode_image(img2, 64)
        })
    
    for data in plates['results']:
        candidates = data['candidates']
        p1 = candidates[0]['plate']
        c1 = candidates[0]['confidence']
        p2 = candidates[1]['plate']
        c2 = candidates[1]['confidence']
        p3 = candidates[2]['plate']
        c3 = candidates[2]['confidence']

        x1, x2 = get_plate_coords(data, 'x')
        y1, y2 = get_plate_coords(data, 'y')

        img2 = img[y1:y2, x1:x2]

        plates2.append({
            'uuid': str(uuid.uuid4()),
            'rect': [x1, y1, x2-x1, y2-y1],
            'b64image': encode_image(img2, 64),
            'p1': p1,
            'c1': c1,
            'p2': p2,
            'c2': c2,
            'p3': p3,
            'c3': c3
        })

    response = {
        'uuid': str(uuid.uuid4()),
        'hostname': HOSTHOSTNAME,
        'path': pathname.replace(TARGET, HOSTTARGET, 1),
        'created_at': datetime.datetime.now(),
        'b64image': encode_image(img, 256),
        'ellapsed': human_time(ellapsed), 
        'type': 'monitor',
        'faces': faces2,
        'plates': plates2
    }

    #print("bundle:", response)
    return response


def send_to_mongo(response):
    event_id = album.insert_one(response).inserted_id
    print("ID in MongoDB:", event_id)


def send_to_rabbitmq(response):
    response['created_at'] = str(response['created_at'])
    response['_id'] = str(response['_id'])
    body = json.dumps(response)
    #print(body)
    print("Size of json body:", len(body))
    
    while True:
        try:
            channel.basic_publish(exchange='',
                            routing_key='hello',
                            body=body,
                            mandatory=True)
            break
        except pika.exceptions.AMQPConnectionError:
            print("Connection was lost, reconnecting")
            reconnect_rabbitmq()

    print("RabbitMQ msg sent")


def process_file(pathname):
    size = os.path.getsize(pathname)

    if size >= 140:
        start_time = time.monotonic()

        img = cv2.imread(pathname, cv2.IMREAD_COLOR)
        fc.read(img)
        faces = fc.result()
        print("faces detected:", faces)

        plates = alpr.recognize_file(pathname)
        print("License plates detected:", faces)

        ellapsed = time.monotonic() - start_time

        response = prepare_response(img, pathname, ellapsed, faces, plates)
        send_to_mongo(response)
        send_to_rabbitmq(response)
        sys.stdout.flush()
    else:
        print("Size is too small", pathname, size)



class Handler(pyinotify.ProcessEvent):
    def process_IN_CLOSE_WRITE(self, event):
        try:
            print("Detected event for IN_CLOSE_WRITE:", event.pathname)
            process_file(event.pathname)
        except Exception as err:
            traceback.print_exc()
            print(err)
            print(err.__class__)
            print("sorry :/")
        sys.stdout.flush()

print("Starting WatchManager")
wm = pyinotify.WatchManager()
handler = Handler()
notifier = pyinotify.Notifier(wm, default_proc_fun=handler)
wm.add_watch(TARGET, pyinotify.IN_CLOSE_WRITE)

print("Starting loop")
notifier.loop()
notifier.stop()

