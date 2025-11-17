#!/usr/bin/env bash
set -euo pipefail

tmp_namespaced_resources=$(kubectl api-resources --namespaced=true --output=name --verbs=list)
mapfile -t namespaced_resources <<< "$tmp_namespaced_resources"

for nr in "${namespaced_resources[@]}"; do
  if ! tmp_kg=$(kubectl get "$nr" --output=json 2>&1); then
    echo "❌ error on '$nr': $tmp_kg"
    continue
  fi

  if [[ $tmp_kg == *" is deprecated in v"* ]]; then
    echo "🪦 deprecated '$nr'"
    continue
  fi

  items_length=$(jq '.items | length' <<< "$tmp_kg")

  if [[ $items_length == "0" ]]; then
    echo "🙅 nothing for '$nr'"
    continue
  fi

  echo
  echo "Namespaced resource: '$nr':"
  jq '.items[].metadata.name' <<< "$tmp_kg"
  echo
done
