#!/bin/bash
set -xe

ID="$1"
TITLE="$2"
DESCRIPTION="$3"
SECTION="$4"
SOURCE="$5"
CONTAINER="$6"
PORT="$7"
COMMAND="$8"

NAMESPACE="gxy-bioc"
GXYRELEASE="gxy"
CHARTVER="4.10.2"


cat << "EOF" > generated/workshop-values.yaml
extraFileMappings:
EOF

cat << "EOF" > generated/workshop-toolconf-values.yaml
configs:
EOF

# Add current tool_conf_bioc.xml
kubectl get -n $NAMESPACE configmap/$GXYRELEASE-galaxy-configs -o yaml | grep -A 10000 "tool_conf_bioc.xml:" | grep -B10000 "      </toolbox>" >> generated/workshop-toolconf-values.yaml

cat generated/workshop-values-$ID.yaml >> generated/workshop-values.yaml

LINETOADD="        <tool file=\"interactive/biocworkshop_$ID.xml\" />"

if grep -qi "<label text=\"$SECTION" generated/workshop-toolconf-values.yaml; then
  sed -i "\|<label text=\"$SECTION|a $LINETOADD"  generated/workshop-toolconf-values.yaml
else
  SECTIONTOADD="      <label text=\"$SECTION\" id=\"$(echo $SECTION | sed 's/[^[:alnum:]]//g' | awk '{print tolower($0)}')\" />"
  sed -i "\|</toolbox>|i $SECTIONTOADD"  generated/workshop-toolconf-values.yaml
  sed -i "\|</toolbox>|i $LINETOADD"  generated/workshop-toolconf-values.yaml
fi

cat generated/workshop-toolconf-values.yaml

cat generated/workshop-values.yaml

helm repo add bioc https://github.com/Bioconductor/helm-charts/raw/devel
helm repo update
helm upgrade --wait --timeout 600s --install --create-namespace -n $NAMESPACE $GXYRELEASE bioc/galaxy --version $CHARTVER --reuse-values -f generated/workshop-toolconf-values.yaml -f generated/workshop-values.yaml
