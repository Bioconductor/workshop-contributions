#!/bin/bash
TORENDER=$(realpath "$1")

cat << "EOF" > install_missing.sh
#!/bin/bash
set -x

QMD=$(realpath "$1")
echo $QMD
mkdir -p /tmp
# Extract missing R pkg or Python module from quarto error message
while ( quarto render $QMD --to html 3>&1 1>&2- 2>&3- ) | grep "there is no package called" > /tmp/rmissingpkg \
 || ( quarto render $QMD --to html 3>&1 1>&2- 2>&3- ) | grep "ModuleNotFoundError: No module named" > /tmp/pymissingmodule;
do
    if [[ -s /tmp/rmissingpkg ]]; then
        RPKG=$(awk '{print $NF}' /tmp/rmissingpkg)
        # Install missing R package
        Rscript -e "if (!require('rspm')) { install.packages('rspm'); rspm::enable(); }; BiocManager::install('$(echo "${RPKG:1:${#RPKG}-2}" | sed "s/'//g")', dependencies=TRUE)" && rm /tmp/rmissingpkg
        # Link reticulate with existing python3
        if [ $RPKG == "'reticulate'" ]; then Rscript -e "library(reticulate); use_python('$(which python3)')"; fi
        
    elif [[ -s /tmp/pymissingmodule ]]; then
        PYMOD=$(awk '{print $NF}' /tmp/pymissingmodule | sed "s/'//g")
        # Install missing python module
        python3 -m pip install $PYMOD && rm /tmp/pymissingmodule
    fi
done

EOF


find $TORENDER -type f -name "*.*md" -print0 | xargs -r0 -i bash install_missing.sh {}
