#!/usr/bin/env bash
set -euo pipefail

# Boilerplate to bring in library script(s).
script_directory="$(cd "$(dirname "${BASH_SOURCE[-1]}")" &> /dev/null && pwd)"
readonly script_directory

for lib in "$script_directory"/lib/*.sh; do
  # shellcheck disable=SC1090
  source "$lib"
done

# The real Dark Souls starts here.
dslog "start"
trap 'dslog "finish"' 0

tool_check docker

if ! docker stats --no-stream &> /dev/null; then
  echo "Docker daemon is not running."
  exit 0
fi

if ! dpa=$(docker ps --quiet | wc -l); then
  err "could not get running containers from host"
fi

if [[ ${dpa//[[:blank:]]/} != "0" ]]; then
  echo
  docker ps
  echo
  err "non-zero number of containers still running"
fi
