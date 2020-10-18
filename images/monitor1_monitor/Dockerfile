FROM diegofpsouza/demo_ws_facedetection:0.0.1

RUN pip3 install pyinotify pymongo pika

WORKDIR /app

COPY src .

RUN cp /libfacedetection/libpyfacedetection.so /app

CMD ["python3", "/app/main.py"]
