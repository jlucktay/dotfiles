#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

mapfile -t Projects < <(gcloud projects list --format=json | jq -r '.[].projectId')

for Project in "${Projects[@]}"; do
    mapfile -t Buckets < <(gsutil ls -p "$Project")

    if ((${#Buckets[@]} == 0)); then
        echo "Project '$Project' has no storage buckets."
        continue
    fi

    echo "Project '$Project':"

    for Bucket in "${Buckets[@]}"; do
        gsutil du -h -s "$Bucket"
    done
done
