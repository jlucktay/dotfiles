#!/usr/bin/env bash
set -euo pipefail

if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
  echo >&2 "${BASH_SOURCE[0]} is not being sourced."
  exit 1
fi

# Check for availability of tool(s).
tool_check() {
  for tool in "$@"; do
    tool_command=$(command -v "$tool" || true)

    if [[ -z $tool_command ]]; then
      err "Can't find '$tool'!"
    fi

    if ! [[ -x $tool_command ]]; then
      err "Can't execute '$tool'!"
    fi
  done
}
