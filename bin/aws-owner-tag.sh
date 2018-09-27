#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

for region in $(awsregions); do
    echo "region: '$region'"

    for ownertag in $(aws resourcegroupstaggingapi get-tag-values --key Owner --region "$region" |
        jq -r .TagValues[] |
        grep -i james |
        grep -i lucktaylor); do

        echo "  Owner tag: '$ownertag'"

        aws resourcegroupstaggingapi get-resources --tag-filters "Key=\"Owner\",Values=\"$ownertag\"" --region "$region" |
            jq -r .ResourceTagMappingList[].ResourceARN |
            grep -v "arn:aws:rds:eu-west-1:580501780015:snapshot:rds:james-lucktaylor-rds-dlg-scor-201" |
            sort -f |
            xargs -n 1 echo "   "
    done
done
