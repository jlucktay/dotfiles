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

tool_check gh rg

### For each image version/tag on the latest release of kind, we want to pull both the sha256 and short versions.

# Parse each image version/tag out of the release body text, and store in an array.
pipe_output=$(gh release view --repo kubernetes-sigs/kind --json body --jq '.body' \
  | rg --only-matching 'kindest/node:v1\.[0-9]{1,}\.[0-9]{1,}@sha256:[0-9a-z]{64}' \
  | sort --unique --ignore-case --version-sort)

# Can't pipe the above output directly into this mapfile call because then the array variable would be scoped to that
# pipe and immediately lost.
mapfile -t kind_image_tags <<< "$pipe_output"

# TODO(jlucktay): filter the array through some logic to parse out the latest patch for each minor release; already
# implemented in the rpi-homelab project when dealing with K8s releases over there.

# For each image version/tag, pull both with and without the sha256 checksum.
for ((i = 0; i < ${#kind_image_tags[@]}; i++)); do
  kit=${kind_image_tags[$i]}

  (
    set -x
    docker pull "$kit"
  )

  echo -n "+ "
  cut -d '@' -f 1 <<< "$kit" | xargs -t docker pull
done
