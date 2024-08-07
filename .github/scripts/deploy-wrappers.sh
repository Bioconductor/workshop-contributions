#!/bin/bash

set -xe

NAMESPACE="gxybioc"
GXYRELEASE="gxy"
CHARTVER="5.14.3"

helm repo add bioc https://github.com/cloudve/helm-charts/raw/master
helm repo update


cat << "EOF" > generated/workshop-values.yaml
extraFileMappings:
EOF

ls generated/* | grep '\-values\-' | xargs -i cat {} >> generated/workshop-values.yaml

helm upgrade --wait --timeout 600s --install --create-namespace -n $NAMESPACE $GXYRELEASE bioc/galaxy --version $CHARTVER --reuse-values -f generated/workshop-values.yaml
