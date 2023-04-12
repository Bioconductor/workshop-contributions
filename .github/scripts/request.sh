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


BIOCVER="devel"
MD5HASH=$(echo "$PKGLIST-$VIGNLIST" | md5sum)
LISTHASH=${MD5HASH:0:8}

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
  CONTAINER="ghcr.io/almahmoud/workshop-contributions:$BIOCVER-$LISTHASH"
  docker manifest inspect "$CONTAINER" && ( echo "$CONTAINER" > generated/$ID.container ) || echo "Container not found."
  if [ ! -f generated/$ID.container ]; then
    cat << EOF >> "generated/$ID.Dockerfile"
FROM ghcr.io/bioconductor/bioconductor:$BIOCVER
RUN Rscript -e 'BiocManager::install(c("$(echo $PKGLIST | sed 's/,/","/g')"), dependencies = c("Depends", "Imports", "LinkingTo", "Suggests"))'
EOF
    echo "$CONTAINER" > generated/$ID.container
  fi
else
  CONTAINER="ghcr.io/bioconductor/bioconductor:$BIOCVER"
  echo "$CONTAINER" > generated/$ID.container
fi

if [ ! -z $VIGNLIST ]; then
  if [ ! -f generated/$ID.Dockerfile ]; then
    cat << EOF >> "generated/$ID.Dockerfile"
FROM $(cat generated/$ID.container)
EOF
    CONTAINER="ghcr.io/almahmoud/workshop-contributions:$BIOCVER-$LISTHASH"
    echo "$CONTAINER" > generated/$ID.container
  fi
  if [[ $VIGNLIST = "https://"* ]]; then
    cat << EOF >> "generated/$ID.Dockerfile"
RUN mkdir -p /tmp && cd /tmp && curl -o install_missing.sh https://raw.githubusercontent.com/Bioconductor/BiocDeployableQuarto/main/.github/scripts/install_missing.sh && echo "$VIGNLIST" | tr ',' '\n' > vignettes && ( cat vignettes | xargs -i curl -O {} ) && find {} -type f -name ".*md" -print0 | xargs -r0 -i bash -c "cp -r {} /home/rstudio/ && bash ../install_missing.sh {}"
EOF
  elif [ ! -z $SOURCE ]; then
    cat << EOF >> "generated/$ID.Dockerfile"
RUN mkdir -p /tmp && cd /tmp && curl -o install_missing.sh https://raw.githubusercontent.com/Bioconductor/BiocDeployableQuarto/main/.github/scripts/install_missing.sh && echo "$VIGNLIST" | tr ',' '\n' > vignettes && git clone $SOURCE && cd $(basename $SOURCE) && install() { find $1 -type f -name ".*md" -print0 | xargs -r0 -I## bash ../install_missing.sh ## ; } ; cat ../vignettes | xargs -i bash -c 'cp -r {} /home/rstudio/ && install {}'
EOF
  fi
fi
