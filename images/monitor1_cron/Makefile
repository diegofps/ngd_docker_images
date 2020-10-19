MONGOSERVER=192.168.1.138
RABBITMQSERVER=192.168.1.138
HOSTTARGET="$(shell pwd)/target"
TARGET="/target"
CONTAINERNAME=mon1-cron
IMAGENAME=monitor1-cron:0.0.1

local:
	docker build -t $(IMAGENAME) .

run:
	mkdir -p $(HOSTTARGET)
	docker rm -f $(CONTAINERNAME) || true
	docker run -v $(HOSTTARGET):/target --name $(CONTAINERNAME) --env TARGET=$(TARGET) --env MONGOSERVER=$(MONGOSERVER) --env RABBITMQSERVER=$(RABBITMQSERVER) $(IMAGENAME)

remote:
	docker buildx build --platform linux/amd64,linux/arm64 --push=true -t diegofpsouza/$(IMAGENAME) .