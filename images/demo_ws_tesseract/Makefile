CONTAINERNAME=tesseract
IMAGENAME=demo_ws_tesseract:0.0.1

local:
	docker rm -f $(CONTAINERNAME) || true
	docker build -t $(IMAGENAME) .
	docker run --name $(CONTAINERNAME) -p 4568:4568 $(IMAGENAME)

remote:
	docker buildx build --platform linux/amd64,linux/arm64 --push=true -t diegofpsouza/$(IMAGENAME) .
