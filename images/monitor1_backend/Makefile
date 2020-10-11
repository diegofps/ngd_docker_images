HOSTIP="192.168.1.138"
CONTAINERNAME=mon1-backend
IMAGENAME=monitor1-backend:v0

all: build

build:
	docker rm -f $(CONTAINERNAME) || true
	docker build -t $(IMAGENAME) .
	docker run --name $(CONTAINERNAME) -p 8081:8081 --env MONGOSERVER=$(HOSTIP) --env RABBITMQSERVER=$(HOSTIP) $(IMAGENAME)
