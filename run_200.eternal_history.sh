#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit 2> /dev/null || true

# Bash before 4.2 (like the default one on Macs these days) doesn't support negative subscripts:
# https://stackoverflow.com/a/61345169/380599
script_name=$(basename "${BASH_SOURCE[${#BASH_SOURCE[@]} - 1]}")

### Check for presence of other tools

# chezmoi
if ! command -v chezmoi &> /dev/null; then
	echo >&2 "$script_name: 'chezmoi' is required but it's not installed:
  https://www.chezmoi.io/install/"
	exit 1
fi

# JQ
if ! command -v jq &> /dev/null; then
	echo >&2 "$script_name: 'jq' is required but it's not installed:
  https://github.com/stedolan/jq/wiki/Installation"
	exit 1
fi

# age
if ! command -v age &> /dev/null; then
	echo >&2 "$script_name: 'age' is required but it's not installed:
  https://github.com/FiloSottile/age"
	exit 1
fi

# 1Password - CLI
if ! command -v op &> /dev/null; then
	echo >&2 "$script_name: 'op' is required but it's not installed:
  https://developer.1password.com/docs/cli/get-started"
	exit 1
fi

archive_destination=$(chezmoi data | jq --exit-status --raw-output '.chezmoi.sourceDir')
age_recipient=$(op read "op://Personal/bash-eternal - age-keygen/Public key" --account=my.1password.com)

# Tar, GZip, and encrypt (with age) the eternal history file
tar -cvz --options='compression-level=9' "$HOME/.bash_eternal_history" \
	| age --recipient "$age_recipient" > "$archive_destination/bash_eternal_history.tar.gz.age"

### To restore this file:
# AGE_KEY=$(gmktemp)
# op read "op://Private/npeylxznmvprgbfm7mnqa3jkgi/Private key" --account=my.1password.com > "$AGE_KEY"
# cd "$(chezmoi data | jq --exit-status --raw-output '.chezmoi.sourceDir')"
# age --decrypt --identity "$AGE_KEY" --output bash_eternal_history.tar.gz bash_eternal_history.tar.gz.age
# rm --force "$AGE_KEY"
# tar zxvf bash_eternal_history.tar.gz
