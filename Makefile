IMAGE_NAME := baseimage
USER_NAME ?= $(USER)
BASE_IMAGE ?= nvidia/cudagl:10.0-runtime-ubuntu18.04

all: docker ssh

.PHONY: build

# create an ssh key for the user of the container
ssh:
	mkdir -p $@
	ssh-keygen -b 2048 -t rsa -f $@/id_rsa -q -N ""

docker: Dockerfile ssh
	nvidia-docker build -t $(USER)/$(IMAGE_NAME) \
	--build-arg USER_NAME=$(USER_NAME) \
	--build-arg BASE_IMAGE=$(BASE_IMAGE) \
	-f Dockerfile .
