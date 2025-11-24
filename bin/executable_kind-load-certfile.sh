#!/usr/bin/env bash
set -euo pipefail

# Boilerplate to bring in library script(s).
script_directory="$(cd "$(dirname "${BASH_SOURCE[-1]}")" &> /dev/null && pwd)"
readonly script_directory

for lib in "$script_directory"/lib/*.sh; do
  # shellcheck disable=SC1090
  source "$lib"
done

dslog "start"
trap 'dslog "finish"' 0

tool_check docker kind

# Define command-line flags with the 'shflags' library
DEFINE_string 'name' 'kind' 'name of a kind cluster' 'n'

# Parse the command-line
FLAGS "$@" || exit $?
eval set -- "${FLAGS_ARGV}"

# Look for certs to load into the cluster
HOST_CERT_DIR="${HOST_CERT_DIR:-"$HOME/etc/ca-certificates"}"
readonly NODE_CERT_DIR="/etc/ssl/certs"

containers="$(kind get nodes --name="$FLAGS_name" 2> /dev/null)"
if [[ $containers == "" ]]; then
  echo >&2 "❌ No 'kind' nodes found for a cluster named '$FLAGS_name'."
  exit 1
fi

while IFS= read -r container; do
  for certfile in "$HOST_CERT_DIR"/**; do
    # Copying certificate into container
    pop_gum docker cp "$certfile" "${container}:${NODE_CERT_DIR}"
    docker cp "$certfile" "${container}:${NODE_CERT_DIR}"
  done

  # Updating CA certificates in container
  pop_gum docker exec "$container" update-ca-certificates
  docker exec "$container" update-ca-certificates

  # Restarting containerd
  pop_gum docker exec "$container" systemctl restart containerd
  docker exec "$container" systemctl restart containerd
done <<< "$containers"
