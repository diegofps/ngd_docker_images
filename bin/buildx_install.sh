#!/bin/sh

sudo apt update
sudo apt-get install -y qemu-user-static

export DOCKER_BUILDKIT=1

docker build --platform=local -o . git://github.com/docker/buildx
mkdir -p ~/.docker/cli-plugins && mv buildx ~/.docker/cli-plugins/docker-buildx

