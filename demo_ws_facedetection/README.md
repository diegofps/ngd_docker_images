# About

This image is based on the face detection library from [ShiqiYu/libfacedetection](https://github.com/ShiqiYu/libfacedetection)

# Using with Docker

```bash
docker run -d --name demo_openalpr -p 4568:4568 diegofpsouza/demo_ws_facedetection:0.0.1
```

# Usage Example

```bash
time curl -F 'imagefile=@/path/to/faces/image_0001.jpg' localhost:4568/recognize
```