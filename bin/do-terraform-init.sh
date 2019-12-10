#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob globstar
IFS=$'\n\t'

script_name=$(basename "${BASH_SOURCE[-1]}")

# We might need to use JQ later; make sure it's present
if ! command -v jq > /dev/null; then
  echo >&2 "'jq' not found! Please install: https://stedolan.github.io/jq/download/"
  exit 1
fi

if ! command -v grealpath > /dev/null; then
  echo >&2 "$script_name: grealpath was not found; install GNU coreutils: https://formulae.brew.sh/formula/coreutils"
  exit 1
fi

# Figure out key location within bucket based on the top level of the git repo we're (probably) currently in
top_level="$(grealpath .)"
top_level_before="$top_level"

while [ ! -d "$top_level/.git" ]; do
  top_level="$(grealpath "$top_level/..")"

  if [ "$top_level" = "/" ]; then
    echo "Root hit, returning!"
    exit 2
  fi
done

if [ "$top_level_before" = "$top_level" ]; then
  echo "You're already at the top level of the repo!"
  exit 3
fi

top_level="$top_level/"
key_base="$(gpwd)"
key_base="${key_base#$top_level}"
desired_state_key="$(echo "$key_base/terraform.tfstate" | tr '[:upper:]' '[:lower:]')"

# Before initialising anything else, we need to check for (and possibly remove) an existing Terraform directory
current_state_key=""

# TODO: update to handle GCP backend, in addition to AWS
if [ -d ".terraform" ]; then
  if [ -f ".terraform/terraform.tfstate" ]; then
    current_state_key="$(jq -r '.backend.config.key' .terraform/terraform.tfstate)"
  fi

  # Only remove if the current initialised state doesn't line up
  if [ "$desired_state_key" != "$current_state_key" ] && [ "$current_state_key" != "" ]; then
    find .terraform -type d -not -path .terraform -not -iname "plugins" -exec rm -rfv -- {} +
    rm -fv .terraform/terraform.tfstate
  fi
fi

# Announce init
echo "Initialising Terraform with following dynamic values:"
printf '\tbucket:\t\t%s\n' "${TF_VAR_state_bucket:-}"
printf '\tdynamodb_table:\t%s\n' "${TF_VAR_state_dynamodb:-}"
printf '\tkey:\t\t%s\n' "$desired_state_key"
printf '\tregion:\t\t%s\n' "${TF_VAR_region:-}"

# Run the initialisation
terraform init \
  -backend-config="bucket=${TF_VAR_state_bucket:-}" \
  -backend-config="dynamodb_table=${TF_VAR_state_dynamodb:-}" \
  -backend-config="key=$desired_state_key" \
  -backend-config="region=${TF_VAR_region:-}"
