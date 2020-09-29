# image_pandas
Pandas-ready image based on Ubuntu 18.04, compiled for amd64 and arm64

# Usage Example

Step 1: Create an app using pandas (./src/app.py)

```python
## src/app.py
#!/usr/bin/python3

import pandas as pd

df = pd.DataFrame({'Aluno' : ["Wilfred", "Abbie", "Harry", "Julia", "Carrie"],
                   'Faltas' : [3,4,2,1,4],
                   'Prova' : [2,7,5,10,6],
                   'Seminário': [8.5,7.5,9.0,7.5,8.0]})

print(df)
```

Step 2: Create a Dockerfile based on this image (./Dockerfile)

```
## Dockerfile
FROM diegofpsouza/pandas

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
docker buildx build --platform linux/amd64,linux/arm64 --push=true -t diegofpsouza/pandas:0.0.1 .
```
