

# Build and deploy to docker hub

## Configure docker buildx (First time only)

```bash
sudo apt-get install -y qemu-user-static
export DOCKER_BUILDKIT=1
docker build --platform=local -o . git://github.com/docker/buildx
mkdir -p ~/.docker/cli-plugins && mv buildx ~/.docker/cli-plugins/docker-buildx
```

## Prepare the build image (After every reboot)

```bash
docker run --rm --privileged docker/binfmt:a7996909642ee92942dcd6cff44b9b95f08dad64
docker buildx create --use --name mybuilder
docker buildx inspect --bootstrap
docker update --restart=always buildx_buildkit_mybuilder0
```

## Build the image and push to docker hub

```bash
docker buildx build --platform linux/amd64,linux/arm64 --push=true -t diegofpsouza/bigdata_hadoop:0.0.1 .
```

# Build and run locally

## Build the image

```bash
docker build -t bigdata_spark:0.0.1 .
```

## Run it (choose one of the modes)

```bash
docker run -p 7077:7077 -p 8080:8080 -e SPARK_MODE=master \
    -it --name=spark-master bigdata_spark:0.0.1

docker run -p -e SPARK_MODE=worker \
    -it --name=spark-worker bigdata_spark:0.0.1

docker run -e SPARK_MODE=client \
    -it --name=spark-client bigdata_spark:0.0.1
```

## To remove the containers

```bash
docker rm spark-master spark-worker spark-client
```
