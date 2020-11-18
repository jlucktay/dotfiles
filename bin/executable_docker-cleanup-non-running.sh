#!/usr/bin/env bash
#
# Removes all the docker images that are not associated with a running container.

set -euo pipefail

mapfile -t images < <(docker images --no-trunc --quiet)

for container in $(docker ps --all --quiet); do
  image=$(docker inspect --format '{{.Image}}' "$container")
  images=("${images[@]/$image/}") # subtract container's image from array
done

if [ ${#images[@]} -ge 1 ] && [ ${#images[0]} -gt 0 ]; then
  docker rmi --force "${images[@]}"
fi
