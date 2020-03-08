#!/usr/bin/env bash
set -euo pipefail
shopt -s globstar nullglob
IFS=$'\n\t'

script_name=$(basename "${BASH_SOURCE[-1]}")

### Check for presence of other tools

# chezmoi
hash chezmoi 2> /dev/null || {
  echo >&2 "$script_name: 'chezmoi' is required but it's not installed:
  https://github.com/twpayne/chezmoi/blob/master/docs/INSTALL.md"
  exit 1
}

# JQ
hash jq 2> /dev/null || {
  echo >&2 "$script_name: 'jq' is required but it's not installed:
  https://github.com/stedolan/jq/wiki/Installation"
  exit 1
}

# zip
hash zip 2> /dev/null || {
  echo >&2 "$script_name: 'zip' is required but it's not installed"
  exit 1
}

if ! zip_secret="$(chezmoi data | jq --exit-status --raw-output '.bash_eternal_history.zip_secret')"; then
  echo "$script_name: couldn't fetch zip secret from 'chezmoi data'"
  exit 1
fi

# zip --version:

# Copyright (c) 1990-2008 Info-ZIP - Type 'zip "-L"' for software license.
# This is Zip 3.0 (July 5th 2008), by Info-ZIP.

# Compiled with gcc 4.2.1 Compatible Apple LLVM 10.0.1 (clang-1001.0.37.14) for Unix (Mac OS X) on Feb 22 2019.

# Options in use:
#   -u    update   - add new files/update existing files only if later date
#   -j        junk directory names (store just file names)
#   -v        verbose operation (just "zip -v" shows version information)
#   -o        make zipfile as old as latest entry
#   -1 to -9  compress fastest to compress best (default is 6)
#   -P pswd   use standard encryption, password is pswd

#   zip options archive_name file file ...
if ! zip_destination="$(chezmoi data | jq --exit-status --raw-output '.chezmoi.sourceDir')"; then
  echo "$script_name: couldn't fetch source directory from 'chezmoi data'"
  exit 1
fi

zip -u -j -v -o -9 -P "$zip_secret" "$zip_destination/bash_eternal_history.zip" "$HOME/.bash_eternal_history"
