#!/usr/bin/env bash
set -euo pipefail

if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
  echo >&2 "${BASH_SOURCE[0]} is not being sourced."
  exit 1
fi

# Bash before 4.4 (like the default one on Macs these days) doesn't have this option:
# https://news.ycombinator.com/item?id=24738359
shopt -s inherit_errexit 2> /dev/null || true

# Bash before 4.2 (like the default one on Macs these days) doesn't support negative subscripts:
# https://stackoverflow.com/a/61345169/380599
SCRIPT_NAME=$(basename "${BASH_SOURCE[${#BASH_SOURCE[@]} - 1]}")
declare -rx SCRIPT_NAME
