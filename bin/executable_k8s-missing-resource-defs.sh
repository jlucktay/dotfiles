#!/usr/bin/env bash
set -euo pipefail

kubectl get pod --all-namespaces --output=go-template-file="$HOME/etc/k8s-container-resources.gotmpl"
