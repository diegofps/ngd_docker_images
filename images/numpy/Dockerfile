FROM ubuntu:18.04

ENV DEBIAN_FRONTEND="noninteractive"
ENV LANGUAGE="en_US.UTF-8"
ENV LC_ALL="en_US.UTF-8"
ENV LANG="en_US.UTF-8"

RUN apt update && apt install language-pack-en -yq
RUN apt install python3 python3-pip python3-dev -yq
RUN pip3 install cython 
RUN pip3 install numpy

