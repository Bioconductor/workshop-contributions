#!/bin/bash
# Usage: bash archive_section.sh sectionid generated/workshop-toolconf-values.yaml

section_id="$1"
filename="$2"

#Placeholder for newlines to make sed easier, and escape spaces to leave starting indentation intact
TOOLCONFTOADD=$(awk '/tool_conf_bioc.xml/,/integrated_tool_panel.xml/' $filename | awk "/$section_id/,/<label/" | head -n -1 | sed '0,/>/{s/label text/section name/; s#/>#>#}' | sed ':a;N;$!ba;s/\n/@NEWLINE@/g;s/ /\\ /g')
INTEGRATEDTOADD=$(awk '/integrated_tool_panel.xml/,/<\/toolbox>/' $filename | awk "/$section_id/,/<label/" | head -n -1 | sed '0,/>/{s/label text/section name/; s#/>#>#}' | sed ':a;N;$!ba;s/\n/@NEWLINE@/g;s/ /\\ /g')

startid="id=\"$section_id\""
endtext="<label text="

awk -v start_pattern="$startid" -v end_pattern="$endtext" '
  $0 ~ start_pattern {
    in_block = 1
    next
  }
  in_block {
    if ($0 ~ end_pattern) {  in_block = 0 }
    else { next }
  }
  1
' "$filename" > /tmp/newfile


echo 'configs:' > $filename
cat /tmp/newfile | grep -m 1 -A100000 "tool_conf_bioc.xml:" | grep -m 1 -B100000 "</toolbox>" | sed "\|id=\"archived\"|a ${TOOLCONFTOADD}@NEWLINE@        </section>" | sed 's/@NEWLINE@/\n/g' >> $filename
cat /tmp/newfile | grep -m 1 -A100000 "integrated_tool_panel.xml:" | grep -m 1 -B100000 "</toolbox>" | sed "\|id=\"archived\"|a ${INTEGRATEDTOADD}@NEWLINE@        </section>" | sed 's/@NEWLINE@/\n/g' >> $filename

