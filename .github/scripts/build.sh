#!/bin/bash

set -xe

ID=$1
CONTAINER=$(cat generated/$ID.container)


docker buildx imagetools inspect "$CONTAINER" && ( echo "Container found" ) || \
 ( echo "Container not found. Building" && cat generated/$ID.Dockerfile && \
   docker build . -f generated/$ID.Dockerfile -t $CONTAINER &&\
   docker push $CONTAINER )

