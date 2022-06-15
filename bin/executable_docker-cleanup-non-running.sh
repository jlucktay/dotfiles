#!/usr/bin/env bash
#
# Removes all the docker images that are not associated with a running container.

set -euo pipefail

docker_images=$(docker images --no-trunc --quiet)
mapfile -t images <<< "$docker_images"

dps_all=$(docker ps --all --quiet)
while IFS= read -r container; do
  image=$(docker inspect --format '{{.Image}}' "$container")
  images=("${images[@]/$image/}") # subtract container's image from array
done <<< "$dps_all"

if [[ ${#images[@]} -ge 1 ]] && [[ ${#images[0]} -gt 0 ]]; then
  docker rmi --force "${images[@]}"
fi
