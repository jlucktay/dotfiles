#!/usr/bin/env bash
set -euo pipefail

gcloud_projects_list=$(gcloud projects list --format=json | jq -r '.[].projectId')
mapfile -t projects <<< "$gcloud_projects_list"

for project in "${projects[@]}"; do
	gsutil_ls=$(gsutil ls -p "$project")
	mapfile -t buckets <<< "$gsutil_ls"

	if [[ ${#buckets[@]} -eq 0 ]] || [[ -z ${buckets[0]} ]]; then
		echo "Project '$project' has no storage buckets."
		continue
	fi

	echo "Project '$project':"

	for bucket in "${buckets[@]}"; do
		gsutil du -a -h -s "$bucket"
	done
done
