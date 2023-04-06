#!/bin/bash
set -xe

ID="$1"
TITLE="$2"
DESCRIPTION="$3"
SECTION="$4"
SOURCE="$5"
CONTAINER="$6"
PORT="$7"
COMMAND="$8"

mkdir -p generated

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



