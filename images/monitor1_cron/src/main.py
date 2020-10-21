#!/usr/bin/env python3

from parquet_digester import ParquetFileDigester, ParquetFaceDigester, ParquetLicensePlateDigester
from csv_digester import CSVFileDigester, CSVFaceDigester, CSVLicensePlateDigester
from pymongo import MongoClient, ASCENDING, DESCENDING

import datetime
import time
import json
import pika
import sys
import os


HOSTHOSTNAME = os.getenv("HOSTHOSTNAME", "Unknown")
MONGOSERVER = os.getenv('MONGOSERVER', '192.168.1.138')
MONGOUSER = os.getenv('MONGOUSER', 'mongoadmin')
MONGOPASS = os.getenv('MONGOPASS', 'secret')
MONGOPORT = int(os.getenv('MONGOPORT', '27017'))
TARGET = os.getenv('TARGET', './')
BUFFERSIZE = int(os.getenv('BUFFERSIZE', '10000'))
RABBITMQSERVER = os.getenv('RABBITMQSERVER', '192.168.1.138')

FILES_CSV = os.path.join(TARGET, "files.csv")
FACES_CSV = os.path.join(TARGET, "faces.csv")
PLATES_CSV = os.path.join(TARGET, "plates.csv")
FILES_PARQUET = os.path.join(TARGET, "files.parquet")
FACES_PARQUET = os.path.join(TARGET, "faces.parquet")
PLATES_PARQUET = os.path.join(TARGET, "plates.parquet")


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
    

def compression_level(old, new):
    if new < old:
        return "{:.2f}%".format((1.0 - (new / old)) * 100)
    else:
        return "+{:.2f}%".format((1.0 - (old / new)) * 100)

def human_size(size):

    size = float(size)
    if size < 1024:
        return "{:.2f}B".format(size)
    
    size /= 1024
    if size < 1024:
        return "{:.2f}KB".format(size)
    
    size /= 1024
    if size < 1024:
        return "{:.2f}MB".format(size)
    
    size /= 1024
    if size < 1024:
        return "{:.2f}GB".format(size)
    
    size /= 1024
    if size < 1024:
        return "{:.2f}TB".format(size)
    
    size /= 1024
    if size < 1024:
        return "{:.2f}PB".format(size)
    
    size /= 1024
    if size < 1024:
        return "{:.2f}EB".format(size)
    
    size /= 1024
    if size < 1024:
        return "{:.2f}ZB".format(size)
    
    size /= 1024
    return "{:.2f}YB".format(size)


print("Starting MongoClient")
cliente = MongoClient(MONGOSERVER, port=MONGOPORT, username=MONGOUSER, password=MONGOPASS)
banco = cliente['monitor-database']
album = banco['events']


print("Starting Backup")
start_time = time.monotonic()
num_files = 0
num_faces = 0
num_plates = 0

with CSVFileDigester(FILES_CSV, BUFFERSIZE) as files_csv:
    with CSVFaceDigester(FACES_CSV, BUFFERSIZE) as faces_csv:
        with CSVLicensePlateDigester(PLATES_CSV, BUFFERSIZE) as plates_csv:
            with ParquetFileDigester(FILES_PARQUET, BUFFERSIZE) as files_parquet:
                with ParquetFaceDigester(FACES_PARQUET, BUFFERSIZE) as faces_parquet:
                    with ParquetLicensePlateDigester(PLATES_PARQUET, BUFFERSIZE) as plates_parquet:
                    
                        for file in album.find():
                            typ = file["type"] if "type" in file else "Unknown"
                            
                            if typ == "monitor" or typ == "faces":
                                print("Performing monitor event Backup")
                                num_files += 1
                                file["_id"] = str(file["_id"])
                                file["b64image"] = str(file["b64image"])
                                files_csv.add(file)
                                files_parquet.add(file)
                                
                                if "faces" in file:
                                    for face in file["faces"]:
                                        num_faces += 1
                                        faces_csv.add(file["_id"], face)
                                        faces_parquet.add(file["_id"], face)
                                
                                if "plates" in file:
                                    for plate in file["plates"]:
                                        num_plates += 1
                                        plates_csv.add(file["_id"], plate)
                                        plates_parquet.add(file["_id"], plate)
                            elif typ == "cron":
                                print("Not implemented yet: cron event backup")
                            
                            else:
                                print("Unknown event type:", typ)


ellapsed = time.monotonic() - start_time

# Broadcast completion event using RabbitMQ

files_csv_size = os.path.getsize(FILES_CSV)
files_parquet_size = os.path.getsize(FILES_PARQUET)
faces_csv_size = os.path.getsize(FACES_CSV)
faces_parquet_size = os.path.getsize(FACES_PARQUET)
plates_csv_size = os.path.getsize(PLATES_CSV)
plates_parquet_size = os.path.getsize(PLATES_PARQUET)

response = {
    "type": "cron",
    "created_at": datetime.datetime.now(),
    "ellapsed": human_time(ellapsed),
    "hostname": HOSTHOSTNAME,
    "table": {
        "headers": [
            {
                "text": "Type",
                "value": "name",
                "align": 'start'
            },
            {
                "text": "Items",
                "value": "items"
            },
            {
                "text": "CSV size",
                "value": "csv_size"
            },
            {
                "text": "Parquet size",
                "value": "parquet_size"
            },
            {
                "text": "Compression",
                "value": "compression_level"
            }
        ],
        "data": [
            {
                "name": "Files",
                "items": num_files,
                "csv_size": human_size(files_csv_size),
                "parquet_size": human_size(files_parquet_size),
                "compression_level": compression_level(files_csv_size, files_parquet_size)
            },
            {
                "name": "Faces",
                "items": num_faces,
                "csv_size": human_size(faces_csv_size),
                "parquet_size": human_size(faces_parquet_size),
                "compression_level": compression_level(faces_csv_size, faces_parquet_size)
            },
            {
                "name": "License Plates",
                "items": num_plates,
                "csv_size": human_size(plates_csv_size),
                "parquet_size": human_size(plates_parquet_size),
                "compression_level": compression_level(plates_csv_size, plates_parquet_size)
            }
        ]
    }
}

print("Sending response to MongoDB")
event_id = album.insert_one(response).inserted_id
print("ID in MongoDB:", event_id)


print("Sending response to RabbitMQ")
response["created_at"] = str(response["created_at"])
response['_id'] = str(response['_id'])

while True:
    try:
        connection = pika.BlockingConnection(pika.ConnectionParameters(RABBITMQSERVER))
        channel = connection.channel()
        channel.queue_declare(queue='hello')

        channel.basic_publish(exchange='',
                        routing_key='hello',
                        body=json.dumps(response),
                        mandatory=True)
        break
    except:
        print("Failed to connect to RabbitMQ, retrying in 5s")
        time.sleep(5)

print("All done :)")
