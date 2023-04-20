FROM ghcr.io/almahmoud/bioc2022_tidytranscriptomics:42f4e2e
RUN  cd /home/rstudio && echo "vignettes/*" | tr ',' '\n' > vignlist && git clone https://github.com/tidytranscriptomics-workshops/bioc2022_tidytranscriptomics && cd bioc2022_tidytranscriptomics && curl -o install.sh https://raw.githubusercontent.com/Bioconductor/workshop-contributions/main/.github/scripts/install_missing.sh && cat ../vignlist | xargs -i bash install.sh {} && rm ../vignlist
