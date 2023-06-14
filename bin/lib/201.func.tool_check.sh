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

    if [[ -z $tool_first_word ]]; then
      err "Can't find command from first word of '$tool'!"
    fi

    if ! type -t "$tool_first_word" &> /dev/null; then
      err "Can't find type for '$tool_first_word'!"
    fi

    if ! hash "$tool_first_word" &> /dev/null; then
      err "Can't determine path for '$tool'!"
    fi
  done
}
