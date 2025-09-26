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

tool_check gh kubectl rg

### For the image version/tag on the latest release of kind, we want to pull both the sha256 and short versions that match the minor version of our local 'kubectl'.

# Check the minor version of the local 'kubectl'.
if ! kubectl_minor_version=$(kubectl version --client --output=json 2> /dev/null | jq --raw-output .clientVersion.minor); then
  err "getting kubectl's minor version"
fi

# Parse each image version/tag out of the release body text, and store in an array.
if ! pipe_output=$(gh release view --repo kubernetes-sigs/kind --json body --jq '.body' \
  | rg --only-matching "kindest/node:v1\.$kubectl_minor_version\.[0-9]{1,}@sha256:[0-9a-z]{64}" \
  | sort --unique --ignore-case --version-sort); then
  err "parsing image tags from GitHub release"
fi

# Can't pipe the above output directly into this mapfile call because then the array variable would be scoped to that pipe and immediately lost.
mapfile -t kind_image_tags <<< "$pipe_output"

if [[ ${#kind_image_tags[@]} -ne 1 ]]; then
  err "found ${#kind_image_tags[@]} elements matching minor version, but was expecting exactly 1"
fi

# Pull the image that matches the minor version of the local 'kubectl', both with and without the sha256 checksum.
pop_gum podman pull "${kind_image_tags[0]}"
podman pull "${kind_image_tags[0]}"

if ! trimmed_tag=$(cut -d '@' -f 1 <<< "${kind_image_tags[0]}"); then
  err "trimming tag '${kind_image_tags[0]}' with 'cut'"
fi

pop_gum podman pull "$trimmed_tag"
podman pull "$trimmed_tag"
