#!/usr/bin/env bash
set -euo pipefail

if [[ -z ${1:-} ]] || [[ ! -d $1 ]]; then
  echo >&2 "Please provide a source directory as the first argument!"
  exit 1
fi
