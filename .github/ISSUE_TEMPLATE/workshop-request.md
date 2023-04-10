---
name: Workshop Request
about: How to request adding your workshop to workshop.bioconductor.org
title: "[Section Name] Workshop Title"
labels: ''
assignees: ''

---

**DO NOT INCLUDE REQUESTS IN THE FIRST COMMENT.**
**PLEASE POST THIS TEMPLATE UNCHANGED THEN FOLLOW ITS INSTRUCTIONS IN A NEW COMMENT**


#General Notes
This repository serves as a mostly automated pipeline for deploying workshops to the [Bioconductor Workshop](https://workshop.bioconductor.org).

All commands need to be written on the first line of the comment, in a single line, starting with the `/command` and containing all `parameter="value in here"` pairs on a single line with no newlines. You may include newline characters (`\n`) in your parameter text, and these will later be evaluated by the script.

#Public request
Unless you are a member of the Bioconductor core team or an administrator of this repository, you can only perform `/request` commands in this space. Some parameters are universal to all requests, namely the Title, Description, Source URL, and Section on the workshop instance. You may request your workshop be added to an existing section, or request a new Section name.
Below is an example of the an incomplete request with all mandatory parameters:
```
/request id="myworkshopuniqueid" title="Bold Text" description="unbolded text next to the title" section="Conference 1996" source="https://github.com/super/repository" 
```
This request will then need to be completed with an additional 1-2 parameters depending on your source for the workshop.

We currently support 3 types of submissions:

1) `docker=` parameter for pre-built RStudio containers (such as Orchestra workshops built based on [BuildABiocWorkshop](https://github.com/Bioconductor/BuildABiocWorkshop))
Below is an example of a full `/request` command for a workshop with a pre-built docker container:
```
/request id="tidybioc2022" title="Tidy Transcriptomics" description="For Single-Cell RNA Sequencing Analyses" section="Smorgasbord 2023" source="https://github.com/tidytranscriptomics-workshops/bioc2022_tidytranscriptomics" docker="ghcr.io/tidytranscriptomics-workshops/bioc2022_tidytranscriptomics:latest"
```

2) `vignettes=` parameter for Rmd/qmd workshops.

Note that when any `Rmd` or `qmd` files are pulled as part of a request including vignettes, the script will only deploy successfully if the vignettes can successfully render. In the process, all dependencies will be automatically scraped and installed in the resulting container image, making it optional to explicitly mention dependencies.

2) a) In-source vignettes, especially useful for example if your Rmd references other files (eg: images), in which case you should include them in your source repository. Parameter represents a comma-separated list of relative paths (with wildcards accepted) from your source repository. Eg: `vignettes="vignettes/*,images/*"` will copy all files from your source repository under those two subdirectories.

Below is an example of a full request with in-source vignettes:
```
/request id="annotation316" title="Genomic Annotation Resources" description="with Bioconductor annotation package" section="Smorgasbord 2023" source="https://github.com/Bioconductor/annotation" vignettes="vignettes/*"
```

2) b) markdown file urls, in the form of a comma-separated list of URLs. eg: `vignettes="https://raw.githubusercontent.com/Bioconductor/annotation/devel/vignettes/Annotation_Resources.Rmd,https://raw.githubusercontent.com/Bioconductor/annotation/devel/vignettes/Annotating_Genomic_Ranges.Rmd"`. This can especially be useful for people unfamiliar with github, who could write a self-contained Rmd file in RStudio, paste it at https://gist.github.com where single files can be hosted with no directory structure or `git` operations.

3) `pkglist=` which can be used with or without the `vignettes=` option, in order to add a list of Bioconductor and/or CRAN packages to the resulting auto-built container image for this request. It should be passed as a comma-separated list of package names. eg: `pkglist="VariantAnnotation,AnnotationHub,TxDb.Hsapiens.UCSC.hg19.knownGene"`

Every request must contain one of the 3 above parameters, in addition to the mandatory parameters.

You may add any comments or information or special requests after the second line, but the first line must contain only the `/command` and its parameters.

#Admin request
Bioconductor Core Team and repository admins will be able to deploy vetted requests to one of two servers. These requests take the same parameters as the `/request` command, but go through with building and deploying the changes. When the request does not include a `docker=` parameter, the image building might delay a response by a couple of hours for package-intensive workshops.

The `/test` command will deploy the instance to our test server, where the requester can verify the aesthetics as well as functionality of the workshop and request any changes.

The `/publish` command will deploy the final approved workshop to the production instance.

The best way for an admin to populate these requests is copy-paste the last passing full `/request` command and all parameters from the requester, and replace the `/request` command with the appropriate deployment directive.
