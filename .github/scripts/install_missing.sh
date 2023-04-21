#!/bin/bash
TORENDER=$(realpath "$1")
if [ ! -f "install_missing.sh" ]
then
    curl -o install_missing.sh https://raw.githubusercontent.com/Bioconductor/BiocDeployableQuarto/main/.github/scripts/install_missing.sh
fi

find $TORENDER -type f -name "*.*md" -print0 | xargs -r0 -i bash install_missing.sh {}
