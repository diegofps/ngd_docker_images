# image_demo_ws_openalpr
Openalpr webserver demo

# Using with Docker

```bash
docker run -d --name demo_openalpr -p 4568:4568 diegofpsouza/demo_ws_openalpr:0.0.1
```

# Usage Example

```bash
time curl -F 'imagefile=@/path/to/license/plates/image_0001.jpg' localhost:4568/recognize
```