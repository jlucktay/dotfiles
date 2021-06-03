#!/usr/bin/env bash
set -euo pipefail

script_name=$(basename "${BASH_SOURCE[-1]}")

### Check for presence of other tools

# chezmoi
if ! command -v chezmoi &> /dev/null; then
  echo >&2 "$script_name: 'chezmoi' is required but it's not installed:
  https://github.com/twpayne/chezmoi/blob/master/docs/INSTALL.md"
  exit 1
fi

# JQ
if ! command -v jq &> /dev/null; then
  echo >&2 "$script_name: 'jq' is required but it's not installed:
  https://github.com/stedolan/jq/wiki/Installation"
  exit 1
fi

# zip
if ! command -v zip &> /dev/null; then
  echo >&2 "$script_name: 'zip' is required but it's not installed"
  exit 1
fi

chezmoi_data=$(chezmoi data)

if ! zip_destination="$(jq --exit-status --raw-output '.chezmoi.sourceDir' <<< "$chezmoi_data")"; then
  echo "$script_name: couldn't fetch source directory from 'chezmoi data'"
  exit 1
fi

if ! zip_secret="$(jq --exit-status --raw-output '.bash_eternal_history.zip_secret' <<< "$chezmoi_data")"; then
  echo "$script_name: couldn't fetch zip secret from 'chezmoi data'; aborting"
  exit 0
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
zip -u -j -v -o -9 -P "$zip_secret" "$zip_destination/bash_eternal_history.zip" "$HOME/.bash_eternal_history"
