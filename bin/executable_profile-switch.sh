#!/usr/bin/env bash
set -euo pipefail

export profile=${1:?}

set -x

yq --inplace '.profile = strenv(profile)' "$HOME/.local/share/chezmoi/.chezmoidata.yaml"
task --dir "$HOME/.local/share/chezmoi/" --taskfile "$HOME/.local/share/chezmoi/Taskfile.chezmoi.yaml" data

ln -fsv "application_default_credentials.$profile.json" "$HOME/.config/gcloud/application_default_credentials.json"
gcloud config configurations activate "$profile"

chezmoi apply "$HOME/.config/aws/config" "$HOME/.terraform.d/credentials.tfrc.json" "$HOME/.terraformrc"
