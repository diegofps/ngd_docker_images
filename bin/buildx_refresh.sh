#!/bin/sh

docker run --rm --privileged docker/binfmt:a7996909642ee92942dcd6cff44b9b95f08dad64
docker buildx create --use --name mybuilder
docker buildx inspect --bootstrap
docker update --restart=always buildx_buildkit_mybuilder0

