#!/usr/bin/env bash
set -euo pipefail

buckets=(belgium finland netherlands singapore taiwan)

for bucket in "${buckets[@]}"; do
  gsutil du -h -s "gs://katka-$bucket"
done
