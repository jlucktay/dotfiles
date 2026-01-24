#!/usr/bin/env bash
set -euo pipefail

declare -rx PROFILE=${1:?}

set -x

yq --inplace '.profile = strenv(PROFILE)' "$HOME/.local/share/chezmoi/.chezmoidata.yaml"
task --taskfile "$HOME/.local/share/chezmoi/Taskfile.chezmoi.yaml" data

ln -fsv "application_default_credentials.$PROFILE.json" "$HOME/.config/gcloud/application_default_credentials.json"
gcloud config configurations activate "$PROFILE"

chezmoi apply "$HOME/.config/aws/config" "$HOME/.terraform.d/credentials.tfrc.json" "$HOME/.terraformrc"
