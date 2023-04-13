#!/bin/bash
TOCOPY=$(realpath "$1")
if [ ! -f "install_missing.sh" ]
then
    curl -o install_missing.sh https://raw.githubusercontent.com/Bioconductor/BiocDeployableQuarto/main/.github/scripts/install_missing.sh
fi
cp -r $TOCOPY /home/rstudio/
find $TOCOPY -type f -name "*.*md" -print0 | xargs -r0 -i bash install_missing.sh {}
