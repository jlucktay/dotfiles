#!/usr/bin/env bash

script_name=$(basename "${BASH_SOURCE[-1]}")

if ! chezmoi_source="$(chezmoi data | jq --exit-status --raw-output '.chezmoi.sourceDir')"; then
  echo "$script_name: couldn't fetch source directory from 'chezmoi data'"
  exit 1
fi

function process_list() {
  # Parameter #1 is the command to generate the list
  # Parameter #2 is the name of the list

  # Parse out the command name and make sure it is available
  cmd_name=$(awk '{print $1}' <<< "$1")

  if ! hash "$cmd_name" &> /dev/null; then
    echo "${BASH_SOURCE[-1]} > ${FUNCNAME[0]}: command '$cmd_name' not found; aborting"
    return
  fi

  # Print command and first argument
  printf "%s: [%s] " "$script_name" "$(gdn)"
  awk '{print $1, $2}' <<< "$1"

  # If the command is 'brew' then make sure we're current before kicking off the lists
  if [ "$cmd_name" == "brew" ]; then
    brew update
  fi

  if ! cmd_output="$(eval "$1")"; then
    : # No-op; skipping errors
  fi

  sort --ignore-case <<< "$cmd_output" > "$(realpath "$chezmoi_source/lists/text/list.$2.txt")"
}

# Git repos I have checked out locally
git_list_cmd="find \"$HOME\" -type d -name \".git\" \
    -not -path \"*/.cache/*\" \
    -not -path \"*/.glide/cache/*\" \
    -not -path \"*/.terraform/*\" \
    -not -path \"*/go/pkg/dep/sources/*\" \
    -not -path \"*/Library/*\" \
    -execdir pwd \\; 2>/dev/null"

process_list "$git_list_cmd" "git"

# Go binaries
if [[ -v GOPATH ]]; then
  go_bin_list_cmd="find $GOPATH/bin -type f"

  process_list "$go_bin_list_cmd" "go.bin"
fi

# Homebrew
process_list "brew tap" "brew.tap"
process_list "brew list -1" "brew"
process_list "brew cask list -1" "brew.cask"

# NPM
npm_list_cmd="npm list --depth=0 --global --parseable"

process_list "$npm_list_cmd" "npm"

# VSCode extensions
vscode_list_cmd="code --list-extensions"

process_list "$vscode_list_cmd" "vscode"
