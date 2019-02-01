#!/bin/bash

# call
# $> ./connect.sh
# or
# $> USER_NAME=myname ./connect.sh
USER_NAME=${USER_NAME:=$USER}

ssh "${USER_NAME}"@127.0.0.1 -i ssh/id_rsa -p 2222 -X
