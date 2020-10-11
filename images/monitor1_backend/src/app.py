#!/usr/bin/env python3

from flask import Flask, render_template, make_response, jsonify
from flask_socketio import SocketIO, emit
from flask_cors import CORS, cross_origin
from pymongo import MongoClient, ASCENDING, DESCENDING

import threading
import pika
import time
import sys
import os


RABBITMQSERVER = os.getenv('RABBITMQSERVER', '192.168.1.138')
MONGOSERVER = os.getenv('MONGOSERVER', '192.168.1.138')
MONGOUSER = os.getenv('MONGOUSER', 'mongoadmin')
MONGOPASS = os.getenv('MONGOPASS', 'secret')
MONGOPORT = int(os.getenv('MONGOPORT', '27017'))

print("Starting backend server")
print(RABBITMQSERVER)
print(MONGOSERVER)


# Connect to mongodb
cliente = MongoClient(MONGOSERVER, port=MONGOPORT, username=MONGOUSER, password=MONGOPASS)
banco = cliente['monitor-database']
album = banco['events']


# Init flask server
app = Flask(__name__)
CORS(app, resources={r"/test/*": {"origins": "*"}})
app.config['SECRET_KEY'] = 'hdsfgksdukjfgasudjfghasjkfgsdahfgsdjhkfgdsjhf'


# Init websocket
socketio = SocketIO(app, cors_allowed_origins="*")


# Connect to rabbitmq
class RabbitListener(threading.Thread):

    def __init__(self):
        print("Starting RabbitListener")
        super().__init__()

    def callback(self, ch, method, properties, body):
        print("Received RabbitMQ event, forwarding to WebSocket")
        socketio.emit('event', {'data': body}, namespace="/test")

    def run(self):
        print("Starting RabbitMQ listening thread")

        while True:
            try:
                connection = pika.BlockingConnection(pika.ConnectionParameters(RABBITMQSERVER))
                channel = connection.channel()

                channel.queue_declare(queue='hello')

                channel.basic_consume(queue='hello',
                                    auto_ack=True,
                                    on_message_callback=self.callback)

                print('Listening on RabbitMQ')
                channel.start_consuming()
            except KeyboardInterrupt:
                print("Bye")
                raise
            except:
                print("RabbitMQ connection error, reconnecting in 5s")
                time.sleep(5)

rl = RabbitListener()
rl.start()


# Server html methods
#@app.route('/flask')
#def index():
#    return render_template('index.html')


# Server json api
@app.route('/events')
def events():
    print("Returning events")
    data = list(album.find().limit(10).sort('created_at', DESCENDING))

    for item in data:
        item["_id"] = str(item["_id"])

    return jsonify(data)


# Wesocket events
# @socketio.on('my event', namespace='/test')
# def test_message(message):
#     emit('my response', {'data': message['data']})

# @socketio.on('my broadcast event', namespace='/test')
# def test_broadcast(message):
#     emit('my response', {'data': message['data']}, broadcast=True)

@cross_origin()
@socketio.on('connect', namespace='/test')
def test_connect():
    print("Client connected")
    #emit('my response', {'data': 'Connected'})

@socketio.on('disconnect', namespace='/test')
def test_disconnect():
    print('Client disconnected')


# Start the app
if __name__ == '__main__':
    socketio.run(app)
