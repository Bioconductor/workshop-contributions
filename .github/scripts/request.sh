#!/bin/bash

set -xe

while getopts ":i:t:d:s:u:c:p:m:k:v:b:" opt; do
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
    m) RAWCOMMAND="$OPTARG"
    ;;
    k) PKGLIST="$OPTARG"
    ;;
    v) VIGNLIST="$OPTARG"
    ;;
    b) BEGINFILE="$OPTARG"
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


COMMAND=$(echo $RAWCOMMAND | sed "s/\\\\\"/'/g")

BIOCVER="devel"
MD5HASH=$(echo "$PKGLIST-$VIGNLIST-$CONTAINER-$BEGINFILE" | md5sum)
LISTHASH=${MD5HASH:0:8}

mkdir -p generated

if [ ! -z $CONTAINER ]; then

  docker buildx imagetools inspect "$CONTAINER"

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
fi

if [ ! -z $PKGLIST ]; then
  CONTAINER="ghcr.io/bioconductor/workshop-contributions:$BIOCVER-$LISTHASH"
  docker buildx imagetools inspect "$CONTAINER" && ( echo "$CONTAINER" > generated/$ID.container ) || echo "Container not found."
  if [ ! -f generated/$ID.Dockerfile ]; then
    if [ ! -f generated/$ID.container ]; then
      echo "ghcr.io/bioconductor/bioconductor:$BIOCVER" > generated/$ID.container
    fi
    cat << EOF >> "generated/$ID.Dockerfile"
FROM $(cat generated/$ID.container)
RUN echo $PKGLIST | tr ',' '\n' > /tmp/pkglist && cat /tmp/pkglist | xargs -i Rscript -e "if(BiocManager::install(c('{}'), dependencies = c('Depends', 'Imports', 'LinkingTo', 'Suggests')) %in% rownames(installed.packages())) q(status = 0) else q(status = 1)"
EOF
    echo "$CONTAINER" > generated/$ID.container
  fi
elif [ -z $CONTAINER ]; then
  CONTAINER="ghcr.io/bioconductor/bioconductor:$BIOCVER"
  echo "$CONTAINER" > generated/$ID.container
fi

if [ ! -z $VIGNLIST ]; then
  if [ ! -f generated/$ID.Dockerfile ]; then
    cat << EOF >> "generated/$ID.Dockerfile"
FROM $(cat generated/$ID.container)
EOF
    CONTAINER="ghcr.io/bioconductor/workshop-contributions:$BIOCVER-$LISTHASH"
    echo "$CONTAINER" > generated/$ID.container
  fi
  if [[ $VIGNLIST = "https://"* ]]; then
    cat << EOF >> "generated/$ID.Dockerfile"
RUN cd /home/rstudio && echo "$VIGNLIST" | tr ',' '\n' > vignettes && ( cat vignettes | xargs -i curl -O {} ) && curl -o install.sh https://raw.githubusercontent.com/Bioconductor/workshop-contributions/main/.github/scripts/install_missing.sh && bash install.sh .
EOF
  elif [ ! -z $SOURCE ]; then
    cat << EOF >> "generated/$ID.Dockerfile"
RUN cd /home/rstudio && echo "$VIGNLIST" | tr ',' '\n' > vignettes && git clone $SOURCE && cd $(basename $SOURCE) && curl -o install.sh https://raw.githubusercontent.com/Bioconductor/workshop-contributions/main/.github/scripts/install_missing.sh && cat ../vignettes | xargs -i bash install.sh {}
EOF
  fi
fi
