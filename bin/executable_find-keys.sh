#!/usr/bin/env bash
set -euo pipefail

fd -e json | while read -r j; do
	if has_key=$(jq --exit-status '.private_key' "$j" 2> /dev/null); then
		has_key_trimmed=$(cut -c 1-100 <<< "$has_key")
		printf "%s\n%-50s\n\n" "$j" "$has_key_trimmed"
	fi
done
