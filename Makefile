IMAGE_NAME := baseimage
BASE_IMAGE ?= nvidia/cudagl:10.0-runtime-ubuntu18.04

USER_NAME ?= $(USER)
USER_UID ?= $(shell id -u)

SSH_KEY_USER = ~/.ssh/id_rsa.pub

all: docker ssh

.PHONY: build

# prepare ssh key for the user of the container
ssh:
	mkdir -p $@
ifneq ("$(wildcard $(SSH_KEY_USER))","")
	# copy it from user keys if available
	cp $(SSH_KEY_USER) ssh/id_rsa.pub
else
	# make it one otherwise
	ssh-keygen -b 2048 -t rsa -f $@/id_rsa -q -N ""
endif

docker: Dockerfile ssh
	nvidia-docker build -t $(USER)/$(IMAGE_NAME) \
	--build-arg BASE_IMAGE=$(BASE_IMAGE) \
	--build-arg USER_NAME=$(USER_NAME) \
	--build-arg USER_UID=$(USER_UID) \
	-f Dockerfile .

clean:
	nvidia-docker image rm $(USER)/$(IMAGE_NAME)
