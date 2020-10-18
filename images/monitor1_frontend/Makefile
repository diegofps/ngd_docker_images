HOSTIP="192.168.1.138"
CONTAINERNAME=mon1-frontend
IMAGENAME=monitor1-frontend:0.0.1

local:
	docker rm -f $(CONTAINERNAME) || true
	docker build -t $(IMAGENAME) .
	docker run --name $(CONTAINERNAME) -p 8080:8080 $(IMAGENAME)

remote:
	docker buildx build --platform linux/amd64,linux/arm64 --push=true -t diegofpsouza/$(IMAGENAME) .