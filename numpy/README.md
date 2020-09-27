# image_numpy
Numpy-ready image based on Ubuntu 18.04, compiled for amd64 and arm64

# Usage Example

Step 1: Create an app using numpy (./src/app.py)

```python
## src/app.py
#!/usr/bin/python3

import numpy as np

data = np.zeros((10,10))
print(data)
```

Step 2: Create a Dockerfile based on this image (./Dockerfile)

```
## Dockerfile
FROM diegofpsouza/numpy:0.0.1

WORKDIR /app

COPY src .

CMD ["python3", "main.py"]
```

Step 3: Build it 

```bash
docker build -t test:v0 .
```

Step 4: Use

```bash
docker run test:v0
```

# Building the image

You will need docker buildx enabled and an authorized account to upload

```bash
docker buildx build --platform linux/amd64,linux/arm64 --push=true -t diegofpsouza/numpy:0.0.1 .
```
