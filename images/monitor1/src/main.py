#!/usr/bin/env python3

from pymongo import MongoClient, ASCENDING, DESCENDING
from pyfacedetectioncnn import FaceDetectionCNN

import pyinotify
import traceback
import datetime
import asyncio
import socket
import base64
import json
import pika
import uuid
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

connection = pika.BlockingConnection(pika.ConnectionParameters(RABBITMQSERVER))
channel = connection.channel()
channel.queue_declare(queue='hello')

cliente = MongoClient(MONGOSERVER, port=MONGOPORT, username=MONGOUSER, password=MONGOPASS)
banco = cliente['monitor-database']
album = banco['events']

fc = FaceDetectionCNN()

print(MONGOSERVER)
print(RABBITMQSERVER)


def encode_image(img, max_size):
    r,c = img.shape[:2]
    factor = max_size / float(r) if r < c else max_size / float(c)
    img = cv2.resize(img, (0, 0), fx=factor, fy=factor)
    success, buffer = cv2.imencode(".jpg", img)

    if not success:
        print("Something bad happened during image encoding")
        return ''
    
    return str(base64.b64encode(bytes(buffer)), 'utf-8')


def process_file(pathname):
    size = os.path.getsize(pathname)

    if size >= 140:
        img = cv2.imread(pathname, cv2.IMREAD_COLOR)
        print("img read")
        fc.read(img)
        faces2 = []
        faces = fc.result()
        
        print("faces detected:", faces)
        
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
                    'rect': r,
                    'confidence': c,
                    'p1': p1,
                    'p2': p2,
                    'p3': p3,
                    'p4': p4,
                    'p5': p5,
                    'b64image': encode_image(img2, 64)
            })
        
        response = {
            'uuid': str(uuid.uuid4()),
            'hostname': HOSTHOSTNAME,
            'path': pathname.replace(TARGET, HOSTTARGET, 1),
            'created_at': datetime.datetime.now(),
            'b64image': encode_image(img, 128),
            'type': 'faces',
            'faces': faces2
        }
        
        print("bundle:", response)
        
        event_id = album.insert_one(response).inserted_id
        print("ID in MongoDB:", event_id)
        
        response['created_at'] = str(response['created_at'])
        response['_id'] = str(response['_id'])
        body = json.dumps(response)
        print(body)
        print("Size of json body:", len(body))
        
        channel.basic_publish(exchange='',
                      routing_key='hello',
                      body=body)
        
        print("RabbitMQ msg sent")
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


wm = pyinotify.WatchManager()
handler = Handler()
notifier = pyinotify.Notifier(wm, default_proc_fun=handler)
wm.add_watch(TARGET, pyinotify.IN_CLOSE_WRITE)

notifier.loop()
notifier.stop()

