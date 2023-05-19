FROM ghcr.io/bioconductor/bioconductor:3.17
RUN sudo apt-get update && sudo apt-get -y install apt-file &&  echo iSEE/iSEEWorkshop2020 | tr ',' '\n' > /tmp/pkglist && cat /tmp/pkglist | xargs -i Rscript -e "if (!require('rspm')) { install.packages('rspm'); rspm::enable(); }; p = BiocManager::install(c('{}'), dependencies = c('Depends', 'Imports', 'LinkingTo', 'Suggests')); if(p %in% rownames(installed.packages())) q(status = 0) else if(strsplit(p, '/')[[1]][2] %in% rownames(installed.packages())) q(status = 0) else q(status = 1)"
