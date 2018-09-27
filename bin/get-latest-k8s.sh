#!/usr/local/bin/bash
set -euo pipefail
IFS=$'\n\t'

GithubApiOutput="$(curl --silent https://api.github.com/repos/kubernetes/kubernetes/releases)"
K8sLatestVersion="$(echo "$GithubApiOutput" | jq --compact-output --monochrome-output --raw-output '.[].name' | grep '^v1\.[0-9]*\.[0-9]*$' | sort --version-sort | tail -n 1)"
K8sFile="$HOME/kubernetes.$K8sLatestVersion.tar.gz"
DownloadUrl="$(echo "$GithubApiOutput" | jq --raw-output '.[] | select( .name == "'"$K8sLatestVersion"'" ) | .assets[].browser_download_url')"
WgetCmd="wget --no-clobber --output-document=\"$K8sFile\" \"$DownloadUrl\""

# echo "wget command: '$WgetCmd'"

eval "$WgetCmd"
