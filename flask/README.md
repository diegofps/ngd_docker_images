# Flask
Flask-ready image based on Ubuntu 18.04, compiled for amd64 and arm64

# Usage Example

Step 1: Create a flask app (./src/app.py)

```python
## src/app.py
from flask import Flask, jsonify

app = Flask(__name__)
app.config['JSON_AS_ASCII'] = False

@app.route('/')
def home():
    return jsonify(answer="42")
```

Step 2: Create a Dockerfile based on this image (./Dockerfile)

```
## Dockerfile
FROM diegofpsouza/flask:0.0.1

WORKDIR /app

COPY src .

EXPOSE 4568

CMD ["flask", "run", "--host=0.0.0.0", "--port=4568"]
```

Step 3: Build it 

```bash
docker build -t test:v0 .
```

Step 4: Use

```bash
docker run -p 4568:4568 test:v0
```

# Building the image

You will need docker buildx enabled and an authorized account to upload

```bash
docker buildx build --platform linux/amd64,linux/arm64 --push=true -t diegofpsouza/flask:0.0.1 .
```

