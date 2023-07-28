#!/bin/bash

set -xe

NAMESPACE="gxy-bioc"
GXYRELEASE="gxy"
CHARTVER="4.10.3"

helm repo add bioc https://github.com/Bioconductor/helm-charts/raw/devel
helm repo update
helm upgrade --wait --timeout 600s --install --create-namespace -n $NAMESPACE $GXYRELEASE bioc/galaxy --version $CHARTVER --reuse-values -f generated/workshop-toolconf-values.yaml
