#!/usr/bin/env bash

if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
	echo >&2 "${BASH_SOURCE[0]} is not being sourced."
	exit 1
fi

# Default logging, with date and script name.
dslog() {
	local log_date
	log_date=$(date +'%Y-%m-%dT%H:%M:%S%z')

	if command -v gum &> /dev/null; then
		local yellow_ld green_sn
		yellow_ld=$(gum style "$log_date" --foreground='#FFFF00')
		green_sn=$(gum style "${SCRIPT_NAME:?}" --foreground='#00FF00')

		gum join "[" "$yellow_ld" "] " "$green_sn" ": " "$*"
	else
		echo "[$log_date] $SCRIPT_NAME: $*"
	fi
}

# Error logging.
err() {
	local err_date
	err_date=$(date +'%Y-%m-%dT%H:%M:%S%z')
	echo >&2 "[$err_date] $SCRIPT_NAME: $*"
	exit 1
}

if command -v gum &> /dev/null; then
	# Make some output text more noticeable.
	pop_gum() {
		local input_text
		input_text="${*-}"
		gum style "$input_text" --foreground='#9400D3' --border=rounded --align=center --padding='0 1' --italic
	}
fi
