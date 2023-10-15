FROM ghcr.io/bioconductor/bioconductor:devel
RUN sudo apt-get update && sudo apt-get -y install apt-file &&  cd /home/rstudio && echo "./*,./episodes/*" | tr ',' '\n' > vignlist && echo "https://github.com/carpentries-incubator/bioc-rnaseq" | tr ',' '\n' > sourcelist && cat sourcelist | xargs -i bash -c 'git clone {} && cp -r $(basename {}) tmpsource/' && cd tmpsource && curl -o install.sh https://raw.githubusercontent.com/Bioconductor/workshop-contributions/main/.github/scripts/install_missing.sh && cat ../vignlist | xargs -i bash install.sh {} && cd .. && rm -rf vignlist tmpsource/ 