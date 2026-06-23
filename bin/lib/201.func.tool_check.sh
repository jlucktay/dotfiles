#!/usr/bin/env bash

if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
	echo >&2 "${BASH_SOURCE[0]} is not being sourced."
	exit 1
fi

# Check for availability of tool(s).
# If any of the strings passed in contain multiple words, only the first word of each string will be checked.
# Skips over leading words containing an equals sign '=' so that variables can be set on a per-run basis.
tool_check() {
	local tool tool_first_word

	for tool in "$@"; do
		tool_first_word=${tool%% *}

		while [[ $tool_first_word == *"="* ]]; do
			tool=${tool#"$tool_first_word "}
			tool_first_word=${tool%% *}
		done

		if [[ -z $tool_first_word ]]; then
			err "Can't find command from first word of '$tool'!"
		fi

		if ! command -v "$tool_first_word" &> /dev/null; then
			err "Can't determine path for '$tool_first_word'!"
		fi

		if ! type -t "$tool_first_word" &> /dev/null; then
			err "Can't find type for '$tool_first_word'!"
		fi
	done
}
