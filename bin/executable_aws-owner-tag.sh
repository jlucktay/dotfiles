#!/usr/bin/env bash
set -euo pipefail

awsregions_output=$(awsregions)
mapfile -t aws_regions <<< "$awsregions_output"

for region in "${aws_regions[@]}"; do
  echo "Region: '$region'"

  aws_rgt_api=$(
    aws resourcegroupstaggingapi get-tag-values --key Owner --region "$region" \
      | jq --raw-output '.TagValues[]' \
      | grep -i "james" \
      | grep -i "lucktaylor"
  )
  mapfile -t owner_tags <<< "$aws_rgt_api"

  for owner_tag in "${owner_tags[@]}"; do
    echo "  Owner tag: '$owner_tag'"

    aws resourcegroupstaggingapi get-resources --tag-filters "Key=\"Owner\",Values=\"$owner_tag\"" --region "$region" \
      | jq -r .ResourceTagMappingList[].ResourceARN \
      | sort -f \
      | xargs -n 1 echo "   "
  done
done
