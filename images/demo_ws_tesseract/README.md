# About

This image is based on the [tesseract-ocr/tesseract](https://github.com/tesseract-ocr/tesseract)

# Using with Docker

```bash
docker run -d --name demo_openalpr -p 4568:4568 diegofpsouza/demo_ws_tesseract:0.0.1
```

# Usage Example

```bash
time curl -F 'imagefile=@/path/to/image/documents/image_0001.jpg' localhost:4568/recognize
```
