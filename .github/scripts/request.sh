#!/bin/bash

set -xe

while getopts ":i:t:d:s:u:c:p:m:k:v:b:e:" opt; do
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
    e) PRECMD="$OPTARG"
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

EXTRACMDS=""
if [ ! -z "$PRECMD" ]; then
  EXTRACMDS="$PRECMD;"
fi

GIVENCOMMAND=$(echo $RAWCOMMAND | sed "s/\\\\\"/'/g")
COMMAND=$GIVENCOMMAND
# if [ ! -z $EXTRACMDS ]; then
#   COMMAND=$(echo $GIVENCOMMAND | sed "s#echo #$EXTRACMDS echo #")
# fi

BIOCVER="devel"
MD5HASH=$(echo "$PKGLIST-$VIGNLIST-$CONTAINER-$BEGINFILE-$EXTRACMDS" | md5sum)
LISTHASH=${MD5HASH:0:8}

mkdir -p generated

if [ ! -z $CONTAINER ]; then

  docker buildx imagetools inspect "$CONTAINER"

  cat << EOF > "generated/workshop-values-$ID.yaml"
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
       s@##PLACEHOLDERCOMMAND##@$(echo "$COMMAND" | sed 's/\&\&/;/g')@g
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
RUN $EXTRACMDS cd /home/rstudio && echo "$VIGNLIST" | tr ',' '\n' > vignlist && ( cat vignlist | xargs -i curl -O {} ) && curl -o install.sh https://raw.githubusercontent.com/Bioconductor/workshop-contributions/main/.github/scripts/install_missing.sh && bash install.sh . && rm vignlist
EOF
  elif [ ! -z $SOURCE ]; then
    cat << EOF >> "generated/$ID.Dockerfile"
RUN $EXTRACMDS cd /home/rstudio && echo "$VIGNLIST" | tr ',' '\n' > vignlist && git clone $SOURCE && cd $(basename $SOURCE) && curl -o install.sh https://raw.githubusercontent.com/Bioconductor/workshop-contributions/main/.github/scripts/install_missing.sh && cat ../vignlist | xargs -i bash install.sh {} && rm ../vignlist
EOF
  fi
fi
