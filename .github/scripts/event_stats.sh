#!/bin/bash
NAMESPACE="$1"
RELEASE="$2"
EVENT="$3"

echo "Stats for $EVENT:"
echo "Total launches: $(kubectl exec -n $NAMESPACE galaxy-$RELEASE-postgres-0 -- bash -c "psql -d galaxy -U galaxydbuser -c \"select count(j.id) from job j where j.tool_id like '%_%$EVENT%';\"" | sed '3q;d' | tr -d ' ')"
echo "Total users: $(kubectl exec -n $NAMESPACE galaxy-$RELEASE-postgres-0 -- bash -c "psql -d galaxy -U galaxydbuser -c \"select count(DISTINCT j.user_id) from job j where j.tool_id like '%_%$EVENT%';\"" | sed '3q;d' | tr -d ' ')"

printf "\nSummary:\n\n| TOOL_ID   | NUM LAUNCHES | NUM USERS |\n|-----------|--------------|-----------|\n"
kubectl exec -n $NAMESPACE galaxy-$RELEASE-postgres-0 -- bash -c "psql -d galaxy -U galaxydbuser -c \"COPY(SELECT tool_id, COUNT(DISTINCT id) AS num_jobs, COUNT(DISTINCT user_id) AS num_users FROM job GROUP BY tool_id) TO STDOUT;\"" | grep "$EVENT" | sed 's/interactivetool_biocworkshop_//g' | sed 's/\s\+/,/g' | sed -e 's/^/| /' -e 's/,/ | /g' -e 's/$/ |/' > /tmp/summarytable

helm get values -n $NAMESPACE $RELEASE | grep 'extraFileMappings' -A100000 > /tmp/gxyvals

cat /tmp/summarytable | awk '{print $2}' > /tmp/tool_ids

touch /tmp/tool_names && rm /tmp/tool_names

cat /tmp/tool_ids | xargs -i bash -c "cat /tmp/gxyvals | grep 'interactivetool_biocworkshop_{}' -A4 | grep 'tool_type' | grep -oP '(?<=name=\")[^\"]*'" > /tmp/tool_names

rm /tmp/gxyvals

paste -d'\t' /tmp/tool_ids /tmp/tool_names | awk -F'\t' '{print "s#" $1 "#" $2 "#g"}' > /tmp/sed_commands

xargs -a /tmp/sed_commands -I{} sed -i -e '{}' /tmp/summarytable

cat /tmp/summarytable

