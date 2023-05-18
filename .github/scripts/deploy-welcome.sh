#!/bin/bash

set -xe

NAMESPACE="gxy-bioc"
GXYRELEASE="gxy"
CHARTVER="4.10.2"

mkdir -p generated

cat << "EOF" > generated/welcome.yaml
extraFileMappings:
EOF

ls | grep "\(css\|html\)$" > /tmp/filelist

while read htmlfile; do
  echo "$htmlfile"
  cat << "EOF" >> generated/welcome.yaml
  /galaxy/server/static/$htmlfile.html:
    useSecret: false
    applyToJob: false
    applyToWeb: true
    applyToSetupJob: false
    applyToWorkflow: false
    applyToNginx: true
    tpl: true
    content: |
EOF
  cat $htmlfile.html | sed 's/^/      /' >> generated/welcome.yaml
done </tmp/filelist

helm repo add bioc https://github.com/Bioconductor/helm-charts/raw/devel
helm repo update
helm upgrade --wait --timeout 600s --install --create-namespace -n $NAMESPACE $GXYRELEASE bioc/galaxy --version $CHARTVER --reuse-values -f generated/welcome.yaml

# Delete nginx pod to be replaced with new one since chart doesn't have extra mappings hash in nginx pod
kubectl get -n $NAMESPACE pods -o name | grep "nginx" | xargs -r -i kubectl delete -n $NAMESPACE {}
