HOSTCONFIG=$(shell pwd)/nginx.conf

all:
	docker run --name mon1_nginx -v $(HOSTCONFIG):/etc/nginx/nginx.conf:ro -d -p 8000:8000 nginx:latest
