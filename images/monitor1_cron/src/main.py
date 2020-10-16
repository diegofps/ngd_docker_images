#!/usr/bin/env python3

from parquet_digester import ParquetFileDigester, ParquetFaceDigester
from csv_digester import CSVFileDigester, CSVFaceDigester
from pymongo import MongoClient, ASCENDING, DESCENDING

import os


MONGOSERVER = os.getenv('MONGOSERVER', '192.168.1.138')
MONGOUSER = os.getenv('MONGOUSER', 'mongoadmin')
MONGOPASS = os.getenv('MONGOPASS', 'secret')
MONGOPORT = int(os.getenv('MONGOPORT', '27017'))
TARGETFOLDER = os.getenv('TARGETFOLDER', './')
BUFFERSIZE = int(os.getenv('BUFFERSIZE', '10000'))

FILES_CSV = os.path.join(TARGETFOLDER, "files.csv")
FACES_CSV = os.path.join(TARGETFOLDER, "faces.csv")
FILES_PARQUET = os.path.join(TARGETFOLDER, "files.parquet")
FACES_PARQUET = os.path.join(TARGETFOLDER, "faces.parquet")

cliente = MongoClient(MONGOSERVER, port=MONGOPORT, username=MONGOUSER, password=MONGOPASS)
banco = cliente['monitor-database']
album = banco['events']


print(album.count())


with CSVFileDigester(FILES_CSV, BUFFERSIZE) as files_csv:
    with CSVFaceDigester(FACES_CSV, BUFFERSIZE) as faces_csv:
        with ParquetFileDigester(FILES_PARQUET, BUFFERSIZE) as files_parquet:
            with ParquetFaceDigester(FACES_PARQUET, BUFFERSIZE) as faces_parquet:
            
                for file in album.find():
                    file["_id"] = str(file["_id"])
                    file["b64image"] = str(file["b64image"])
                    files_csv.add(file)
                    files_parquet.add(file)
                    
                    for face in file["faces"]:
                        faces_csv.add(file["_id"], face)
                        faces_parquet.add(file["_id"], face)

