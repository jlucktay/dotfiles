#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[${#BASH_SOURCE[@]} - 1]}")" &> /dev/null && pwd)"

bats \
  --jobs 8 \
  --print-output-on-failure \
  "${script_dir}"
