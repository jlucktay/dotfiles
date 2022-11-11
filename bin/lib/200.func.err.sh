#!/usr/bin/env bash
set -euo pipefail

if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
  echo >&2 "${BASH_SOURCE[0]} is not being sourced."
  exit 1
fi

# Error logging.
err() {
  local err_date
  err_date=$(date +'%Y-%m-%dT%H:%M:%S%z')
  echo >&2 "[$err_date] ${SCRIPT_NAME:?}: $*"
  exit 1
}
