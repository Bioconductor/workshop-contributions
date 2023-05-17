#!/bin/bash

set -xe

NAMESPACE="gxy-bioc"
GXYRELEASE="gxy"
CHARTVER="4.10.2"

mkdir -p generated

cat << "EOF" > generated/welcome.yaml
extraFileMappings:
  /galaxy/server/static/welcome.html:
    useSecret: false
    applyToJob: false
    applyToWeb: true
    applyToSetupJob: false
    applyToWorkflow: false
    applyToNginx: true
    tpl: true
    content: |
EOF

cat welcome.html | sed 's/^/      /' >> generated/welcome.yaml

cat << "EOF" > generated/welcome.yaml
  /galaxy/server/static/tos.html:
    useSecret: false
    applyToJob: false
    applyToWeb: true
    applyToSetupJob: false
    applyToWorkflow: false
    applyToNginx: true
    tpl: true
    content: |
EOF

cat tos.html | sed 's/^/      /' >> generated/welcome.yaml

helm repo add bioc https://github.com/Bioconductor/helm-charts/raw/devel
helm repo update
helm upgrade --wait --timeout 600s --install --create-namespace -n $NAMESPACE $GXYRELEASE bioc/galaxy --version $CHARTVER --reuse-values -f generated/welcome.yaml

# Delete nginx pod to be replaced with new one since chart doesn't have extra mappings hash in nginx pod
kubectl get -n $NAMESPACE pods -o name | grep "nginx" | xargs -r -i kubectl delete -n $NAMESPACE {}
