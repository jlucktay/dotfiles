#!/usr/bin/env bash
set -euo pipefail

tmp_orgs=$(gcloud organizations list --format=json | jq --raw-output '.[].name')
mapfile -t google_cloud_orgs <<< "$tmp_orgs"

for org in "${google_cloud_orgs[@]}"; do
	split_org=$(cut -d'/' -f2 <<< "$org")
	echo >&2 "Org (split): '$split_org'"

	gcloud container images list-gcr-usage --organization="$split_org" --format=json

	echo >&2
done
