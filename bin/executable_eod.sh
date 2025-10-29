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

tool_check podman gum k3d

if podman info &> /dev/null; then
  dslog "✅ Podman Engine is running."

  if ! ppfn=$(podman ps --format='{{.Names}}'); then
    err "could not get names of running containers from host"
  fi

  mapfile -t running_names < <(printf "%s" "$ppfn")

  if [[ ${#running_names[@]} -gt 0 ]]; then
    echo
    podman ps
    echo
    dslog "🔶 non-zero number of containers/clusters still running"
    echo

    if gum confirm "Remove all running containers/clusters?" --show-output; then
      echo

      # Create a map to track any k3d clusters that are currently running.
      # Depending on how the cluster is configured, it may have multiple containers running.
      declare -A running_k3d_clusters=()

      for running_name in "${running_names[@]}"; do
        # Are any of the containers k3d clusters? If so, use 'k3d cluster delete' instead.

        if [[ $running_name =~ ^k3d- ]] && [[ $running_name =~ -server(-[0-9]+|lb)$ ]]; then
          running_name=${running_name#"k3d-"}
          running_name=${running_name%"${BASH_REMATCH[0]}"}

          # Use pre-increment — where ++ is before the reference to the map — and increase the number value stored against the key.
          # If the key does not already exist, it will be created with a value of 1.
          # Do not use post-increment — where ++ is after the reference to the map — as it will return non-zero for new keys, and halt the script.
          ((++running_k3d_clusters[$running_name]))
        else
          (
            set -x
            podman rm --force "$running_name"
          )
        fi
      done

      # Iterate through the running k3d clusters and run the appropriate delete command just once per cluster, rather than once per container.
      for rkc in "${!running_k3d_clusters[@]}"; do
        (
          set -x
          k3d cluster delete "$rkc"
        )
      done

    fi

    echo
  fi
else
  dslog "🐳❌ Podman Engine is not running."
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

osascript -e 'quit app "Google Chat"'
osascript -e 'quit app "Slack"'
