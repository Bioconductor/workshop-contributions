#!/bin/bash
set -xe

ID="$1"
TITLE="$2"
DESCRIPTION="$3"
SOURCE="$4"
CONTAINER="$5"
PORT="$6"
COMMAND="$7"

mkdir -p generated

docker manifest inspect "$CONTAINER"

cat << EOF >> "generated/workshop-values-$id.yaml"
/galaxy/server/tools/interactive/biocworkshop_$id.xml:
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



