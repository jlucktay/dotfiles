#!/usr/bin/env bash
set -euo pipefail

echo -n "Listing projects..."
gcloud_projects_list=$(gcloud projects list --filter='NOT projectId=sys-*' --format="value(projectId)")
mapfile -t projects <<< "$gcloud_projects_list"
echo " done. Found '${#projects[@]}' projects."

# Keep a running count with an integer variable.
declare -i cluster_count=0

for project in "${projects[@]}"; do
  # Check if GKE is enabled in the project.
  if ! gcloud services list --project="$project" --format=json \
    | jq --exit-status 'any(.[].config.name; . == "container.googleapis.com")' > /dev/null; then

    echo -n "."
    continue
  fi

  # Look up GKE clusters in the project.
  gcloud_project_clusters=$(gcloud container clusters list --project="$project" --format="value(name)")
  mapfile -t project_clusters <<< "$gcloud_project_clusters"

  if [[ ${#project_clusters[@]} -eq 0 ]] || [[ -z ${project_clusters[0]} ]]; then
    echo -n "+"
    continue
  fi

  # If any clusters were found, print a list.
  echo
  echo "Project '$project':"

  for pc in "${project_clusters[@]}"; do
    ((cluster_count += 1))
    echo "- $pc"
  done
done

echo
echo "Final cluster count: $cluster_count"
