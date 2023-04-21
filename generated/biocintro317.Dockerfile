FROM ghcr.io/bioconductor/bioconductor:devel
RUN mkdir -p /tmp && cd /tmp && echo "./*,./episodes/*" | tr ',' '\n' > vignettes && git clone https://github.com/carpentries-incubator/bioc-intro && cd bioc-intro && curl -o install.sh https://raw.githubusercontent.com/Bioconductor/workshop-contributions/main/.github/scripts/install_missing.sh && cat ../vignettes | xargs -i bash install.sh {}
