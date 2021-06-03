#!/usr/bin/env bash
set -euo pipefail

mapfile -t aws_regions < <(awsregions)

for region in "${aws_regions[@]}"; do
  echo "Region: '$region'"

  mapfile -t owner_tags < <(
    aws resourcegroupstaggingapi get-tag-values --key Owner --region "$region" \
      | jq --raw-output '.TagValues[]' \
      | grep -i "james" \
      | grep -i "lucktaylor"
  )

  for owner_tag in "${owner_tags[@]}"; do
    echo "  Owner tag: '$owner_tag'"

    aws resourcegroupstaggingapi get-resources --tag-filters "Key=\"Owner\",Values=\"$owner_tag\"" --region "$region" \
      | jq -r .ResourceTagMappingList[].ResourceARN \
      | sort -f \
      | xargs -n 1 echo "   "
  done
done
