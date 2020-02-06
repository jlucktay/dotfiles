#!/usr/bin/env bash
set -euo pipefail
shopt -s globstar nullglob
IFS=$'\n\t'

github_api_output="$(curl --silent https://api.github.com/repos/kubernetes/kubernetes/releases)"
k8s_latest_version="$(echo "$github_api_output" | jq --compact-output --monochrome-output --raw-output '.[].name' | grep '^v1\.[0-9]*\.[0-9]*$' | sort --version-sort | tail -n 1)"
k8s_file="$HOME/kubernetes.$k8s_latest_version.tar.gz"
download_url="$(echo "$github_api_output" | jq --raw-output '.[] | select( .name == "'"$k8s_latest_version"'" ) | .assets[].browser_download_url')"

wget_args=(--no-clobber "--output-document=$k8s_file" "$download_url")

wget "${wget_args[@]}"
