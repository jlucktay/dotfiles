#!/usr/bin/env bash
set -euo pipefail

if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
  echo >&2 "${BASH_SOURCE[0]} is not being sourced."
  exit 1
fi

# Check for availability of tool(s).
# If any of the strings passed in contain multiple words, only the first word of each string will be checked.
tool_check() {
  for tool in "$@"; do
    tool_first_word=${tool%% *}
    tool_command=$(command -v "$tool_first_word" || true)

    if [[ -z $tool_command ]]; then
      err "Can't find command for '$tool'!"
    fi

    if ! [[ -x $tool_command ]]; then
      err "Can't execute command for '$tool'!"
    fi
  done
}
