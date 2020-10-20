HOSTIP := "192.168.1.138"
HOSTTARGET := "$(shell pwd)/target"
HOSTHOSTNAME := "$(shell hostname)"
CONTAINERNAME := mon1
IMAGENAME := monitor1-monitor:0.0.1

local:
	docker rm -f $(CONTAINERNAME) || true
	docker build -t $(IMAGENAME) .
	docker run -v $(HOSTTARGET):/target --name $(CONTAINERNAME) --env HOSTHOSTNAME=$(HOSTHOSTNAME) --env HOSTTARGET=$(HOSTTARGET) --env MONGOSERVER=$(HOSTIP) --env RABBITMQSERVER=$(HOSTIP) $(IMAGENAME)

remote:
	docker buildx build --platform linux/amd64,linux/arm64 --push=true -t diegofpsouza/$(IMAGENAME) .
