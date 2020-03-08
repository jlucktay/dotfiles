#!/usr/bin/env bash
set -euo pipefail
shopt -s globstar nullglob
IFS=$'\n\t'

buckets=(belgium finland netherlands singapore taiwan)

for bucket in "${buckets[@]}"; do
  gsutil du -h -s "gs://katka-$bucket"
done
