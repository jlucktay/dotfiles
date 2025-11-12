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

tool_check docker gum kind

if docker info &> /dev/null; then
  dslog "✅ Docker daemon is running."

  if ! dpfn=$(docker ps --format='{{.Names}}'); then
    err "could not get names of running containers from host"
  fi

  mapfile -t running_names < <(printf "%s" "$dpfn")

  if [[ ${#running_names[@]} -gt 0 ]]; then
    echo
    docker ps
    echo
    dslog "🔶 non-zero number of containers/clusters still running"
    echo

    if gum confirm "Remove all running containers/clusters?" --show-output; then
      echo

      # Create a map to track any kind clusters that are currently running.
      # Depending on how the cluster is configured, it may have multiple containers running.
      declare -A running_kind_clusters=()

      for running_name in "${running_names[@]}"; do
        # Are any of the containers kind cluster control planes? If so, use 'kind delete cluster' instead.
        if [[ $running_name =~ -control-plane$ ]]; then
          running_name=${running_name%"-control-plane"}

          # Use pre-increment — where ++ is before the reference to the map — and increase the number value stored against the key.
          # If the key does not already exist, it will be created with a value of 1.
          # Do not use post-increment — where ++ is after the reference to the map — as it will return non-zero for new keys, and halt the script.
          ((++running_kind_clusters[$running_name]))
        else
          (
            set -x
            docker rm --force "$running_name"
          )
        fi
      done

      # Iterate through the running kind clusters and run the appropriate delete command just once per cluster, rather than once per container.
      for rkc in "${!running_kind_clusters[@]}"; do
        (
          set -x
          kind delete cluster --name="$rkc"
        )
      done

    fi

    echo
  fi
else
  dslog "🐳❌ Docker daemon is not running."
fi

# Unset the current kubectl context.
tool_check yq

(
  set -x
  yq eval --inplace 'del(.current-context)' "$HOME/.kube/config"
)

# Clear any ongoing AWS sessions.
tool_check assume

(
  set -x
  assume --unset
)

# Close down chat apps.
(
  set -x
  osascript -e 'quit app "Google Chat"'
  osascript -e 'quit app "Slack"'
)
