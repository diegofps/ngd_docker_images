# Opencv4
Opencv4 image based on Ubuntu 18.04, compiled for amd64 and arm64

# Building the image

You will need docker buildx enabled and an authorized account to upload

```bash
docker buildx build --platform linux/amd64,linux/arm64 --push=true -t diegofpsouza/opencv4:0.0.1 .
```
