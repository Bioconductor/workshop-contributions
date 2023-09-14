FROM ghcr.io/bioconductor/bioconductor:devel
RUN sudo apt-get update && sudo apt-get -y install apt-file && curl -o /home/rstudio/EuroBioC2023.tar.gz https://raw.githubusercontent.com/almahmoud/outreach/main/demo/EuroBioC2023/EuroBioC2023.tar.gz && cd /home/rstudio && tar -xvf EuroBioC2023.tar.gz && rm EuroBioC2023.tar.gz; echo microbiome/mia,microbiome/miaViz,microbiome/MGnifyR,ANCOMBC,ComplexHeatmap,ggplot2,knitr,dplyr,tidyr,scater,knitr | tr ',' '\n' > /tmp/pkglist && cat /tmp/pkglist | xargs -i Rscript -e "if (!require('rspm')) { install.packages('rspm'); rspm::enable(); }; p = BiocManager::install(c('{}'), dependencies = c('Depends', 'Imports', 'LinkingTo', 'Suggests')); if(p %in% rownames(installed.packages())) q(status = 0) else if(strsplit(p, '/')[[1]][2] %in% rownames(installed.packages())) q(status = 0) else q(status = 1)"
RUN sudo apt-get update && sudo apt-get -y install apt-file && curl -o /home/rstudio/EuroBioC2023.tar.gz https://raw.githubusercontent.com/almahmoud/outreach/main/demo/EuroBioC2023/EuroBioC2023.tar.gz && cd /home/rstudio && tar -xvf EuroBioC2023.tar.gz && rm EuroBioC2023.tar.gz; cd /home/rstudio && echo "https://raw.githubusercontent.com/almahmoud/outreach/main/demo/EuroBioC2023/workflow.Rmd" | tr ',' '\n' > vignlist && mkdir workshop && cd workshop && ( cat ../vignlist | xargs -i curl -O {} ) && cd .. && cp -r workshop tmpworkshop && curl -o install.sh https://raw.githubusercontent.com/Bioconductor/workshop-contributions/main/.github/scripts/install_missing.sh && bash install.sh tmpworkshop/ && rm -rf tmpworkshop/ vignlist install.sh install_missing.sh && mv workshop/* /home/rstudio/ && rm -rf workshop
