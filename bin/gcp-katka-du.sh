#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

buckets=(belgium finland netherlands singapore taiwan)

for bucket in "${buckets[@]}"; do
    gsutil du -h -s "gs://katka-$bucket"
done
