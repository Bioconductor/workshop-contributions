#!/bin/bash

set -xe

NAMESPACE="gxybioc"
GXYRELEASE="gxy"
CHARTVER="5.14.3"

helm repo add bioc https://github.com/cloudve/helm-charts/raw/master
helm repo update
helm upgrade --wait --timeout 600s --install --create-namespace -n $NAMESPACE $GXYRELEASE bioc/galaxy --version $CHARTVER --reuse-values -f generated/workshop-toolconf-values.yaml
