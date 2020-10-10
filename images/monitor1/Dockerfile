FROM diegofpsouza/demo_ws_facedetection:0.0.1

RUN pip3 install pyinotify

WORKDIR /app

COPY src .

RUN cp /libfacedetection/libpyfacedetection.so /app

CMD ["./main.py"]
