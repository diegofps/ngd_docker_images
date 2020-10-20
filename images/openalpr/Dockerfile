FROM ubuntu:18.04

ENV DEBIAN_FRONTEND="noninteractive"
ENV LANGUAGE="en_US.UTF-8"
ENV LC_ALL="en_US.UTF-8"
ENV LANG="en_US.UTF-8"

RUN apt update && apt install libopencv-dev libtesseract-dev \
    git cmake build-essential libleptonica-dev liblog4cplus-dev libcurl3-dev beanstalkd \
    python3 python3-pip python3-dev -yq

WORKDIR /src

COPY src .

RUN /src/build_install_openalpr.sh

CMD ["bash"]