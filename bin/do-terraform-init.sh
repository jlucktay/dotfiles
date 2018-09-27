#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# We might need to use JQ later; make sure it's present
if ! command -v jq > /dev/null; then
    echo "'jq' not found! Please install: https://stedolan.github.io/jq/download/"
    exit 1
fi

# Figure out key location within bucket based on the top level of the git repo we're (probably) currently in
TopLevel="$(grealpath .)"
TopLevelBefore="$TopLevel"

while [ ! -d "$TopLevel/.git" ]; do
    TopLevel="$(grealpath "$TopLevel/..")"

    if [ "$TopLevel" == "/" ]; then
        echo "Root hit, returning!"
        exit 2
    fi
done

if [ "$TopLevelBefore" == "$TopLevel" ]; then
    echo "You're already at the top level of the repo!"
    exit 3
fi

TopLevel="$TopLevel/"
KeyBase="$(gpwd)"
KeyBase="${KeyBase#$TopLevel}"
DesiredStateKey="$(echo "$KeyBase/terraform.tfstate" | tr '[:upper:]' '[:lower:]')"

# Before initialising anything else, we need to check for (and possibly remove) an existing Terraform directory
CurrentStateKey=""

# TODO: update to handle GCP backend, in addition to AWS
if [ -d ".terraform" ]; then
    if [ -f ".terraform/terraform.tfstate" ]; then
        CurrentStateKey="$(jq -r '.backend.config.key' .terraform/terraform.tfstate)"
    fi

    # Only remove if the current initialised state doesn't line up
    if [ "$DesiredStateKey" != "$CurrentStateKey" ] && [ "$CurrentStateKey" != "" ]; then
        find .terraform -type d -not -path .terraform -not -iname "plugins" -exec rm -rfv -- {} +
        rm -fv .terraform/terraform.tfstate
    fi
fi

# Announce init
echo "Initialising Terraform with following dynamic values:"
printf '\tkey:\t%s\n' "$DesiredStateKey"

# Run the initialisation
terraform init -backend-config="key=$DesiredStateKey" -backend-config="region=${TF_VAR_region:-}"
