# Build and run the image

## Download hadoop precompiled binaries

```bash
cd "~/Sources/ngd_docker_images/images/bigdata_hadoop/data"
./download_data.sh
```

## Build the image locally

```bash
cd "~/Sources/ngd_docker_images/images/bigdata_hadoop"
docker build -t hadoop:0.0.1 .
```

## Start the container using the image built

```bash
sudo kubectl run -it --rm --restart=Never hadoop --image=hadoop:0.0.1 -- bash

docker run -it --name=hadoop -p 9000:9000 --entrypoint=/bin/bash hadoop:0.0.1


docker run -p 9000:9000 -p 8032:8032 -p 8088:8088 -p 9864:9864 \
    -p 9870:9870 -p 19888:19888 -p 8042:8042 -p 9046:9046 \
    -it --name=hadoop-name --entrypoint=/bin/bash hadoop:0.0.1

docker run -it --name=hadoop-data1 --entrypoint=/bin/bash hadoop:0.0.1
```

## Remove the runnign containers

```bash
docker rm hadoop-name hadoop-data1
```
