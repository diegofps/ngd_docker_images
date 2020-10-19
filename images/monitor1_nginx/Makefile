HOSTCONFIG=$(shell pwd)/nginx.conf
CONTAINERNAME=nginx

local:
	docker rm -f $(CONTAINERNAME) || true
	docker run --name $(CONTAINERNAME) -v $(HOSTCONFIG):/etc/nginx/nginx.conf:ro -d -p 8000:8000 nginx:latest

remote:
	echo "this image has no remote build"