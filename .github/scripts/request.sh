#!/bin/bash

set -xe

while getopts ":i:t:d:s:u:c:p:m:k:v:" opt; do
  case $opt in
    i) ID="$OPTARG"
    ;;
    t) TITLE="$OPTARG"
    ;;
    d) DESCRIPTION="$OPTARG"
    ;;
    s) SECTION="$OPTARG"
    ;;
    u) SOURCE="$OPTARG"
    ;;
    c) CONTAINER="$OPTARG"
    ;;
    p) PORT="$OPTARG"
    ;;
    m) COMMAND="$OPTARG"
    ;;
    k) PKGLIST="$OPTARG"
    ;;
    v) VIGNLIST="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    exit 1
    ;;
  esac

  case $OPTARG in
    -*) echo "Option $opt needs a valid argument"
    exit 1
    ;;
  esac
done


BIOCVER="3.16"

mkdir -p generated

if [ ! -z $CONTAINER ]; then

  docker manifest inspect "$CONTAINER"

  cat << EOF >> "generated/workshop-values-$ID.yaml"
  /galaxy/server/tools/interactive/biocworkshop_$ID.xml:
    useSecret: false
    applyToJob: true
    applyToSetupJob: true
    applyToWeb: true
    applyToWorkflow: true
    applyToNginx: true
    tpl: false
    content: |
$(sed """s@##PLACEHOLDERID##@${ID}@g
       s@##PLACEHOLDERNAME##@${TITLE}@g
       s@##PLACEHOLDERDESCRIPTION##@${DESCRIPTION}@g
       s@##PLACEHOLDERSOURCE##@${SOURCE}@g
       s@##PLACEHOLDERCONTAINER##@${CONTAINER}@g
       s@##PLACEHOLDERPORT##@${PORT}@g
       s@##PLACEHOLDERCOMMAND##@${COMMAND}@g
       s@^@      @g""" .github/scripts/rstudio-it-template.yaml)
EOF
  echo "$CONTAINER" > generated/$ID.container

elif [ ! -z $PKGLIST ]; then
  LISTHASH=$(echo $PKGLIST | md5sum)
  CONTAINER="ghcr.io/almahmoud/workshop-contributions:$BIOCVER-$LISTHASH"
  docker manifest inspect "$CONTAINER" && ( echo "$CONTAINER" > generated/$ID.container ) || echo "Container not found."
  if [ -f generated/$ID.container ]; then
    cat << EOF >> "generated/$ID.Dockerfile"
FROM ghcr.io/bioconductor/bioconductor:$BIOCVER
RUN Rscript -e 'BiocManager::install(c("$(echo $PKGLIST | sed 's/,/","/g')"), dependencies = c("Depends", "Imports", "LinkingTo", "Suggests"))'
EOF
  echo "$CONTAINER" > generated/$ID.container
  #docker build . -f generated/$ID.Dockerfile -t $CONTAINER
  fi
else
  CONTAINER="ghcr.io/bioconductor/bioconductor:$BIOCVER"
  echo "$CONTAINER" > generated/$ID.container
fi



