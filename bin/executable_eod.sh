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

if docker info &> /dev/null; then
  dslog "✅ Docker daemon is running."

  if ! dpnq=$(docker ps --no-trunc --quiet); then
    err "could not get running containers from host"
  fi

  mapfile -t running_ids < <(printf "%s" "$dpnq")

  if [[ ${#running_ids[@]} -gt 0 ]]; then
    echo
    docker ps
    echo
    dslog "⚠️ non-zero number of containers still running"
    echo

    if gum confirm "Remove all running containers?" --show-output; then
      echo
      docker rm --force "${running_ids[@]}"
    fi

    echo
  fi
else
  dslog "🐳❌ Docker daemon is not running."
fi

tool_check kubectx

(
  set -x
  kubectx --unset
)

tool_check assume

(
  set -x
  assume --unset
)
