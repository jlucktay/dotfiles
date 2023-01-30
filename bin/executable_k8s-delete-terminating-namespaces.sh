#!/usr/bin/env bash
set -euxo pipefail

for ns in $(kubectl get namespaces --field-selector='status.phase=Terminating' \
  --output=jsonpath='{ .items[*].metadata.name }'); do
  kubectl get namespaces "$ns" --output=json \
    | jq '.spec.finalizers = []' \
    | kubectl replace --filename=- --raw="/api/v1/namespaces/$ns/finalize"
done

for ns in $(kubectl get namespaces --field-selector='status.phase=Terminating' \
  --output=jsonpath='{ .items[*].metadata.name }'); do
  kubectl get namespaces "$ns" --output=json \
    | jq '.metadata.finalizers = []' \
    | kubectl replace --filename=- --raw="/api/v1/namespaces/$ns/finalize"
done
