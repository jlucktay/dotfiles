#!/usr/bin/env bash
set -euo pipefail
shopt -s globstar nullglob
IFS=$'\n\t'

mapfile -t projects < <(gcloud projects list --format=json | jq -r '.[].projectId')

for project in "${projects[@]}"; do
  mapfile -t buckets < <(gsutil ls -p "$project")

  if [[ ${#buckets[@]} -eq 0 ]]; then
    echo "Project '$project' has no storage buckets."
    continue
  fi

  echo "Project '$project':"

  for bucket in "${buckets[@]}"; do
    gsutil du -h -s "$bucket"
  done
done
