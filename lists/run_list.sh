#!/usr/bin/env bash
set -euo pipefail

# Bash before 4.4 (like the default one on Macs these days) doesn't have this option:
# https://news.ycombinator.com/item?id=24738359
shopt -s inherit_errexit 2> /dev/null || true

# Bash before 4.2 (like the default one on Macs these days) doesn't support negative subscripts:
# https://stackoverflow.com/a/61345169/380599
script_name=$(basename "${BASH_SOURCE[${#BASH_SOURCE[@]} - 1]}")

if ! chezmoi_source="$(chezmoi data | jq --exit-status --raw-output '.chezmoi.sourceDir')"; then
  echo "$script_name: couldn't fetch source directory from 'chezmoi data'"
  exit 1
fi

function process_list() {
  # Parameter #1 is the command to generate the list
  # Parameter #2 is the name of the list
  # Parameter #3 (optional) will, if set to anything, skip sorting

  # Parse out the command name (from the first line (NR) only) and make sure it is available
  cmd_name=$(awk 'NR == 1 { print $1 }' <<< "$1")

  if ! hash "$cmd_name" &> /dev/null; then
    echo "$script_name > ${FUNCNAME[0]}: command '$cmd_name' not found; aborting"
    return
  fi

  # Print command and first argument
  current_timestamp=$(TZ=UTC date '+%Y%m%dT%H%M%SZ')
  printf "%s: [%s] " "$script_name" "$current_timestamp"
  awk 'NR == 1 { print $1, $2 }' <<< "$1"

  # If the command is 'brew' then make sure we're up to date before kicking off the lists
  if [[ $cmd_name == "brew" ]]; then
    brew update
  fi

  if ! cmd_output="$(eval "$1")"; then
    : # No-op; skipping errors
  fi

  # Make sure the list directory structure and the file itself all exist.
  list_file_path="$chezmoi_source/lists/text/list.$2.txt"
  mkdir -p "$(basename list_file_path)"
  touch "$list_file_path"

  if [[ -n ${3-} ]]; then
    echo "$cmd_output" > "$list_file_path"
  else
    sort --ignore-case <<< "$cmd_output" > "$list_file_path"
  fi
}

# Git repos I have checked out locally
git_list_cmd="fd '^\.git$' \"$HOME\"/git --hidden --type directory --exec git -C '{//}' rev-parse --show-toplevel"
process_list "$git_list_cmd" "git"

# Go binaries
if command -v gup &> /dev/null; then
  process_list "gup list" "go.bin" skipsort
elif [[ -d "$HOME"/go/bin ]]; then
  process_list "find \"$HOME\"/go/bin -type f" "go.bin"
fi

# Rust binaries
if [[ ! -d $HOME/.cargo/bin ]]; then
  echo "$script_name: No '\$HOME.cargo/bin/' directory found; skipping"
else
  rust_bin_list_cmd="cargo install --list"
  process_list "$rust_bin_list_cmd" "rust.bin" skipsort
fi

# Homebrew
process_list "brew tap" "brew.tap"
process_list "brew list -1 --formula" "brew"
process_list "brew list -1 --cask" "brew.cask"

# pnpm
pnpm_list_cmd='pnpm list --global --json --long \
  | jq --raw-output '\''.[].dependencies | to_entries | .[].value | "\(.homepage):\(.version)"'\'
process_list "$pnpm_list_cmd" "pnpm"

# VSCode extensions
vscode_list_cmd="code --list-extensions"
process_list "$vscode_list_cmd" "vscode"

# Python packages
pip_list_cmd="python3 -m pip list --format freeze"
process_list "$pip_list_cmd" "pip3"

# Ruby gems
gem_list_cmd="gem list --no-verbose"
process_list "$gem_list_cmd" "gem"
