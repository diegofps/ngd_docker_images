FROM ubuntu:18.04

ENV DEBIAN_FRONTEND="noninteractive"
ENV LANGUAGE="en_US.UTF-8"
ENV LC_ALL="en_US.UTF-8"
ENV LANG="en_US.UTF-8"

RUN apt update && apt install language-pack-en -yq

RUN apt install less clang inetutils-ping curl time build-essential net-tools python-q-text-as-data mlocate vim \
    checkinstall cmake pkg-config yasm git gfortran libjpeg8-dev libz-dev \
    libpng-dev libtiff5-dev libavcodec-dev libavformat-dev libswscale-dev \
    libdc1394-22-dev libxine2-dev libv4l-dev libtbb-dev \
    libatlas-base-dev libfaac-dev libmp3lame-dev libtheora-dev libvorbis-dev \
    libxvidcore-dev libopencore-amrnb-dev libopencore-amrwb-dev x264 \
    v4l-utils libgstreamer1.0-dev libgda-5.0-dev libavcodec-dev ffmpeg \
    libopenblas-dev liblapack-dev libeigen3-dev libgtk-3-dev \
    libclutter-1.0-dev libwebkit2gtk-4.0-dev \
    python3 python3-pip python3-dev -yq

WORKDIR /src

COPY src .

RUN /src/build.sh

