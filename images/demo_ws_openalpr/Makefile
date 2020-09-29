all: local

local:
	docker build -t test:v0 .

build:
	docker buildx build --platform linux/amd64,linux/arm64 -t diegofpsouza/demo_ws_openalpr:0.0.1 .

push:
	docker buildx build --platform linux/amd64,linux/arm64 --push=true -t diegofpsouza/demo_ws_openalpr:0.0.1 .
