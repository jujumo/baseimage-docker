#!/bin/bash
IMAGE_NAME=baseimage

nvidia-docker run \
--rm \
--name ${IMAGE_NAME} \
--interactive --tty \
-p 2222:22 \
--runtime=nvidia \
 ${USER}/${IMAGE_NAME} $@
