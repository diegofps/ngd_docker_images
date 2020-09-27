
# Run using docker hub image

```bash

```

# Run from source

## Build the image localy

```bash
docker build -t test:v0 .
```

## Run it

```bash
docker run -d --name test -p 4580:4580 test:v0
``` 

# Build the container

```bash
docker build . -t telemetry:v1
docker tag telemetry:v1 $HOST_IP:27443/telemetry:v1
docker push $HOST_IP:27443/telemetry:v1
```

# Deploy it on every primary machine

```bash
docker run -d --name telemetry -p 4580:4580 --restart=always -e HOST_HOSTNAME=`hostname` -e REFRESH_SECONDS="2" telemetry:v1
```

