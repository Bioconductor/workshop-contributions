#!/bin/bash

set -xe

ID=$1
CONTAINER=$(cat generated/$ID.container)

cat generated/$ID.Dockerfile

docker manifest inspect "$CONTAINER" && ( echo "Container found" ) || \
 ( echo "Container not found. Building" &&\
   docker build . -f generated/$ID.Dockerfile -t $CONTAINER &&\
   docker push $CONTAINER )

