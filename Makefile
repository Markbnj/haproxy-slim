REGISTRY_NAME ?= markbnj
SHELL = /bin/bash
BASE_IMAGE_NAME ?= haproxy-base
IMAGE_NAME ?= haproxy
TAG ?= 1.6.2
LOG_NAME ?= image-build.log
CONTAINER_NAME = haproxy
TEST_PORT = 80

.rm-container:
	if (docker ps -a | grep -q $(CONTAINER_NAME)); then docker rm -f $(CONTAINER_NAME); fi

haproxy:
	docker build --tag=$(REGISTRY_NAME)/$(IMAGE_NAME):$(TAG) --rm=true --force-rm=true config-image | tee config-image/$(LOG_NAME)

.clean-haproxy:
	if (docker images | awk 'NR>1 {print $1":"$2;}' | grep -q $(REGISTRY_NAME)/$(IMAGE_NAME):$(TAG)); then docker rmi $(REGISTRY_NAME)/$(IMAGE_NAME):$(TAG); fi
	rm -f config-image/image-build.log

haproxy-base:
	docker build --tag=$(REGISTRY_NAME)/$(BASE_IMAGE_NAME):$(TAG) --rm=true --force-rm=true base-image | tee base-image/$(LOG_NAME)

.clean-base:
	if (docker images | awk 'NR>1 {print $1":"$2;}' | grep -q $(REGISTRY_NAME)/$(BASE_IMAGE_NAME):$(TAG)); then docker rmi $(REGISTRY_NAME)/$(BASE_IMAGE_NAME):$(TAG); fi
	rm -f base-image/image-build.log

clean: .rm-container .clean-haproxy .clean-base

build: .clean-haproxy haproxy test

build-all: clean haproxy-base haproxy test

run: .rm-container
	docker run -d -h $(CONTAINER_NAME) --name=$(CONTAINER_NAME) -p $(TEST_PORT):80 $(REGISTRY_NAME)/$(IMAGE_NAME):$(TAG)

test: run
	sleep 2
	if (curl localhost:$(TEST_PORT)/test | grep -q "200 OK"); then echo "Test succeeded."; else echo "Test failed."; fi
	docker rm -f $(CONTAINER_NAME)
