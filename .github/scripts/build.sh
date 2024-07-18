#!/bin/bash

set -xe

ID=$1
CONTAINER=$(cat generated/$ID.container)
DOCKERCONTAINER=$(echo $CONTAINER | sed 's/ghcr.io/docker.io/g')


docker buildx imagetools inspect "$CONTAINER" && ( echo "Container found" ) || \
 ( echo "Container not found. Building" && cat generated/$ID.Dockerfile && \
   docker build . -f generated/$ID.Dockerfile -t $CONTAINER -t $DOCKERCONTAINER &&\
   docker push $CONTAINER || ( docker push $DOCKERCONTAINER && echo $DOCKERCONTAINER > generated/$ID.container && git add generated/$ID.container && git commit -m "Container $ID in docker instead" && git push ) )

