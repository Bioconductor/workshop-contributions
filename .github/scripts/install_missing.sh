#!/bin/bash
if [ ! -f ../install_missing.sh ]
then
    ( cd .. & curl -o install_missing.sh https://raw.githubusercontent.com/Bioconductor/BiocDeployableQuarto/main/.github/scripts/install_missing.sh )
fi
find "$1" -type f -name ".*md" -print0 | xargs -r0 -i bash ../install_missing.sh {}
