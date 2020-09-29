
# Run using a docker hub image

```bash
docker run -d --name test -p 4580:4580 diegofpsouza/demo_ws_telemetry:0.0.1
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

# Publish to docker hub

## Build the multiarch image

```bash
docker buildx build --platform linux/amd64,linux/arm64 -t diegofpsouza/demo_ws_telemetry:0.0.1 .
```

## Publish them

```bash
docker buildx build --platform linux/amd64,linux/arm64 --push=true -t diegofpsouza/demo_ws_telemetry:0.0.1 .
```
