HOSTIP="192.168.1.138"
CONTAINERNAME=mon1-backend
IMAGENAME=monitor1-backend:0.0.1

local:
	docker rm -f $(CONTAINERNAME) || true
	docker build -t $(IMAGENAME) .
	docker run --name $(CONTAINERNAME) -p 8081:8081 --env MONGOSERVER=$(HOSTIP) --env RABBITMQSERVER=$(HOSTIP) $(IMAGENAME)

remote:
	docker buildx build --platform linux/amd64,linux/arm64 --push=true -t diegofpsouza/$(IMAGENAME) .