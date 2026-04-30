#!/usr/bin/env bash
set -euo pipefail

declare -rx PROFILE=${1:?}

set -x

yq --inplace '.profile = strenv(PROFILE)' "$HOME/.local/share/chezmoi/.chezmoidata.yaml"
task --taskfile "$HOME/.local/share/chezmoi/Taskfile.chezmoi.yaml" data

ln -fsv "application_default_credentials.$PROFILE.json" "$HOME/.config/gcloud/application_default_credentials.json"
rm -fv "$HOME/.kube/gke_gcloud_auth_plugin_cache"
gcloud config configurations activate "$PROFILE"

chezmoi apply "$HOME/.config/aws/config" "$HOME/.terraform.d/credentials.tfrc.json" "$HOME/.terraformrc"

# Unset the current contexts for kubectl and argocd.
for ctx in "$HOME/.kube/config" "$HOME/.config/argocd/config"; do
	yq eval --inplace 'del(.current-context)' "$ctx"
done
