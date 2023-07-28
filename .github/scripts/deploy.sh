#!/bin/bash

set -xe

while getopts ":i:s:" opt; do
  case $opt in
    i) ID="$OPTARG"
    ;;
    s) SECTION="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    exit 1
    ;;
  esac

  case $OPTARG in
    -*) echo "Option $opt needs a valid argument"
    exit 1
    ;;
  esac
done


NAMESPACE="gxy-bioc"
GXYRELEASE="gxy"
CHARTVER="4.10.3"


cat << "EOF" > generated/workshop-values.yaml
extraFileMappings:
EOF

cat << "EOF" > generated/workshop-toolconf-values.yaml
configs:
EOF

# Add current tool_conf_bioc.xml
kubectl get -n $NAMESPACE configmap/$GXYRELEASE-galaxy-configs -o yaml | grep -m 1 -A100000 "tool_conf_bioc.xml:" | grep -m 1 -B100000 "</toolbox>" >> generated/workshop-toolconf-values.yaml

kubectl get -n $NAMESPACE configmap/$GXYRELEASE-galaxy-configs -o yaml | grep -m 1 -A100000 "integrated_tool_panel.xml:" | grep -m 1 -B100000 "</toolbox>" >> generated/workshop-toolconf-values.yaml

cat generated/workshop-values-$ID.yaml >> generated/workshop-values.yaml

LINETOADD="<tool file=\"interactive/biocworkshop_$ID.xml\" />"

if ! grep -qi "$LINETOADD" generated/workshop-toolconf-values.yaml; then
  if grep -qi "<label text=\"$SECTION" generated/workshop-toolconf-values.yaml; then
    sed -i "\|<label text=\"$SECTION|a \ \ \ \ \ \ \ \ \ \ $LINETOADD"  generated/workshop-toolconf-values.yaml
  else
    SECTIONTOADD="<label text=\"$SECTION\" id=\"$(echo $SECTION | sed 's/[^[:alnum:]]//g' | awk '{print tolower($0)}')\" />"
    sed -i "\|</toolbox>|i \ \ \ \ \ \ \ \ $SECTIONTOADD"  generated/workshop-toolconf-values.yaml
    sed -i "\|</toolbox>|i \ \ \ \ \ \ \ \ \ \ $LINETOADD"  generated/workshop-toolconf-values.yaml
  fi
  sed -i '#integrated_tool_panel.xml#,# *</toolbox># s#file="interactive/biocworkshop_#id="interactivetool_biocworkshop_#' generated/workshop-toolconf-values.yaml
  sed -i '#integrated_tool_panel.xml#,# *</toolbox># s#.xml"##' generated/workshop-toolconf-values.yaml
fi

cat generated/workshop-toolconf-values.yaml

cat generated/workshop-values.yaml

helm repo add bioc https://github.com/Bioconductor/helm-charts/raw/devel
helm repo update
helm upgrade --wait --timeout 600s --install --create-namespace -n $NAMESPACE $GXYRELEASE bioc/galaxy --version $CHARTVER --reuse-values -f generated/workshop-toolconf-values.yaml -f generated/workshop-values.yaml
