HOSTIP="192.168.1.138"
HOSTTARGET="$(shell pwd)/target"
HOSTHOSTNAME="$(shell hostname)"
CONTAINERNAME=mon1
IMAGENAME=monitor1:v0

all: build

build:
	docker rm -f $(CONTAINERNAME) || true
	docker build -t $(IMAGENAME) .
	docker run -v $(HOSTTARGET):/target --name $(CONTAINERNAME) --env HOSTHOSTNAME=$(HOSTHOSTNAME) --env HOSTTARGET=$(HOSTTARGET) --env MONGOSERVER=$(HOSTIP) --env RABBITMQSERVER=$(HOSTIP) $(IMAGENAME)
