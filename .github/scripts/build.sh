#!/bin/bash

set -xe

ID=$1
CONTAINER=$(cat generated/$ID.container)
BIOCVER="3.16"

docker manifest inspect "$CONTAINER" && ( echo "Container found" ) || \
 ( echo "Container not found. Building" &&\
   docker build . -f generated/$ID.Dockerfile -t $CONTAINER &&\
   docker push $CONTAINER )

