# Makefile for Node-RED OpenEEW Device Management

DOCKERHUB_ID:=us.icr.io/openeew-devicemgmt
IMG_NAME:="openeew-devicemgmt"
IMG_VERSION:="2.2"
ARCH:="amd64"

# Store the secrets in a .env file  (see ./.env.example)
# or modify the Makefile "run" rule below to run the
#   docker container with -e environment variables
# or store them directly in the Dockerfile
APIKEY:=

# Leave blank for open DockerHub containers
# CONTAINER_CREDS:=-r "registry.wherever.com:myid:mypw"
# CONTAINER_CREDS:=-r "us.icr.io:iamapikey:token"
CONTAINER_CREDS:=

default: build run

login:
	ibmcloud login --sso
	ibmcloud cr login
	ibmcloud cr region-set us-south
	ibmcloud target -g OpenEEW-Infra
	ibmcloud ks cluster config --cluster c0ioei6w0iv2i68l9q80
	echo ibmcloud cr namespace-add openeew-devicemgmt

build:
	docker build --rm -t $(DOCKERHUB_ID)/$(IMG_NAME):$(IMG_VERSION) .
	docker image prune --filter label=stage=builder --force

dev: stop build
	docker run -it \
			--name ${IMG_NAME} \
			--env-file secrets/env.list \
			-p 1880:1880 \
			$(DOCKERHUB_ID)/$(IMG_NAME):$(IMG_VERSION) /bin/bash

run: stop
	docker run -it \
			--name ${IMG_NAME} \
			--env-file secrets/env.list \
			--restart unless-stopped \
			-p 1880:1880 \
			$(DOCKERHUB_ID)/$(IMG_NAME):$(IMG_VERSION)

test:
	xdg-open http://127.0.0.1:1880/admin

ui:
	xdg-open http://127.0.0.1:1880/ui

push:
	docker push $(DOCKERHUB_ID)/$(IMG_NAME):$(IMG_VERSION)

kube:
	echo kubectl apply -f yaml/devicemgmt-v11.yaml --namespace openeew-devicemgmt
	echo kubectl apply -f yaml/devicemgmt-v11.yaml --namespace default
	kubectl delete deployment openeew-devicemgmt --namespace default
	kubectl apply -f yaml/devicemgmt-22.yaml --namespace default


stop:
	@docker rm -f ${IMG_NAME} >/dev/null 2>&1 || :

clean:
	@docker rmi -f $(DOCKERHUB_ID)/$(IMG_NAME):$(IMG_VERSION) >/dev/null 2>&1 || :

.PHONY: login build dev run push test ui stop clean
