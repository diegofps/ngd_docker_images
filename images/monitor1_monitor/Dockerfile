FROM diegofpsouza/demo_ws_facedetection:0.0.1

RUN pip3 install pyinotify pymongo pika

WORKDIR /app

RUN cp /libfacedetection/libpyfacedetection.so /app

RUN apt update && apt install libopencv-dev libtesseract-dev \
    git cmake build-essential libleptonica-dev liblog4cplus-dev libcurl3-dev beanstalkd \
    python3 python3-pip python3-dev -yq

WORKDIR /src

COPY src/build*.sh .

RUN /src/build_install_openalpr.sh

WORKDIR /app

COPY ./src .

CMD ["/app/main.py"]
