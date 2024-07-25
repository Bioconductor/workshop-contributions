#!/bin/bash
NAMESPACE="$1"
RELEASE="$2"
EVENT="$3"

echo "Stats for $EVENT:"
echo "Total launches: $(kubectl exec -n $NAMESPACE galaxy-$RELEASE-postgres-0 -- bash -c "psql -d galaxy -U galaxydbuser -c \"select count(j.id) from job j where j.tool_id like '%_%$EVENT%';\"" | sed '3q;d' | tr -d ' ')"
echo "Total users: $(kubectl exec -n $NAMESPACE galaxy-$RELEASE-postgres-0 -- bash -c "psql -d galaxy -U galaxydbuser -c \"select count(DISTINCT j.user_id) from job j where j.tool_id like '%_%$EVENT%';\"" | sed '3q;d' | tr -d ' ')"

printf "\nSummary:\n\n| TOOL_ID   | NUM LAUNCHES | NUM USERS |\n|-----------|--------------|-----------|\n"
kubectl exec -n $NAMESPACE galaxy-$RELEASE-postgres-0 -- bash -c "psql -d galaxy -U galaxydbuser -c \"COPY(SELECT tool_id, COUNT(DISTINCT id) AS num_jobs, COUNT(DISTINCT user_id) AS num_users FROM job GROUP BY tool_id) TO STDOUT;\"" | grep "$EVENT" | sed 's/interactivetool_biocworkshop_//g' | sed 's/\s\+/,/g' | sed -e 's/^/| /' -e 's/,/ | /g' -e 's/$/ |/'


