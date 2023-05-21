#!/bin/bash

set -xe

NAMESPACE="gxy-bioc"
GXYRELEASE="gxy"
CHARTVER="4.10.2"

helm repo add bioc https://github.com/Bioconductor/helm-charts/raw/devel
helm repo update


cat << "EOF" > generated/workshop-values.yaml
extraFileMappings:
EOF

ls generated/* | grep '\-values\-' | xargs -i cat {} >> generated/workshop-values.yaml

helm upgrade --wait --timeout 600s --install --create-namespace -n $NAMESPACE $GXYRELEASE bioc/galaxy --version $CHARTVER --reuse-values -f generated/workshop-values.yaml
