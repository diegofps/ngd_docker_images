SAMPLES=/home/diego/Sources/demo_openalpr/datasets/openalpr/
CONTAINERNAME=openalpr
IMAGENAME=openalpr:0.0.1

local:
	docker build -t $(IMAGENAME) .

run:
	docker rm -f $(CONTAINERNAME) || true
	docker run -it -v $(SAMPLES):/samples --name $(CONTAINERNAME) $(IMAGENAME)

remote:
	docker buildx build --platform linux/amd64,linux/arm64 --push=true -t diegofpsouza/$(IMAGENAME) .
