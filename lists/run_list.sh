#!/usr/bin/env bash
set -euo pipefail

# Bash before 4.4 (like the default one on Macs these days) doesn't have this option:
# https://news.ycombinator.com/item?id=24738359
shopt -s inherit_errexit 2> /dev/null || true

# Bash before 4.2 (like the default one on Macs these days) doesn't support negative subscripts:
# https://stackoverflow.com/a/61345169/380599
script_name=$(basename "${BASH_SOURCE[${#BASH_SOURCE[@]} - 1]}")

if ! chezmoi_source="$(chezmoi data | jq --exit-status --raw-output '.chezmoi.sourceDir')"; then
  echo "${script_name}: couldn't fetch source directory from 'chezmoi data'"
  exit 1
fi

if ! command -v realpath; then
  # https://stackoverflow.com/a/3572105/380599
  function realpath() {
    [[ $1 == /* ]] && echo "$1" || echo "${PWD}/${1#./}"
  }
fi

function process_list() {
  # Parameter #1 is the command to generate the list
  # Parameter #2 is the name of the list

  # Parse out the command name and make sure it is available
  cmd_name=$(awk '{ print $1 }' <<< "$1")

  if ! hash "${cmd_name}" &> /dev/null; then
    echo "${BASH_SOURCE[${#BASH_SOURCE[@]} - 1]} > ${FUNCNAME[0]}: command '${cmd_name}' not found; aborting"
    return
  fi

  # Print command and first argument
  current_timestamp=$(gdn)
  printf "%s: [%s] " "${script_name}" "${current_timestamp}"
  awk '{ print $1, $2 }' <<< "$1"

  # If the command is 'brew' then make sure we're up to date before kicking off the lists
  if [[ ${cmd_name} == "brew" ]]; then
    brew update
  fi

  if ! cmd_output="$(eval "$1")"; then
    : # No-op; skipping errors
  fi

  sort --ignore-case <<< "${cmd_output}" > "$(realpath "${chezmoi_source}/lists/text/list.$2.txt")"
}

# Git repos I have checked out locally
git_list_cmd="fd '^\.git$' \"${HOME}\" \
  --hidden --type d \
  --exec git -C '{//}' rev-parse --show-toplevel \
  | grep -v \"\/Library\/\" "

process_list "${git_list_cmd}" "git"

# Go binaries
# https://stackoverflow.com/a/13864829/380599
if [[ -z ${GOPATH+x} ]]; then
  echo "GOPATH is unset, skipping"
else
  go_bin_list_cmd="find ${GOPATH}/bin -type f"
  process_list "${go_bin_list_cmd}" "go.bin"
fi

# Rust binaries
if [[ ! -d ${HOME}/.cargo/bin ]]; then
  echo "No '\$HOME.cargo/bin/' directory found, skipping"
else
  rust_bin_list_cmd="cargo install --list"
  process_list "${rust_bin_list_cmd}" "rust.bin"
fi

# Homebrew
process_list "brew tap" "brew.tap"
process_list "brew list -1 --formula" "brew"
process_list "brew list -1 --cask" "brew.cask"

# NPM
npm_list_cmd="npm list --depth=0 --global --parseable"

### If NVM is installed, use it to iterate across all available versions
brew_prefix_nvm=$(brew --prefix nvm)
# shellcheck disable=SC1091
if [[ -s "${brew_prefix_nvm}/nvm.sh" ]] && . "${brew_prefix_nvm}/nvm.sh" &> /dev/null; then
  nvm_ls=$(nvm ls --no-alias --no-colors)
  nvm_ls_cut=$(cut -c3-15 <<< "${nvm_ls}")
  nvm_ls_cut_tr=$(tr -d ' ' <<< "${nvm_ls_cut}")
  mapfile -t nvm_versions <<< "${nvm_ls_cut_tr}"

  for nvm_version in "${nvm_versions[@]}"; do
    nvm use "${nvm_version}" &> /dev/null
    npm_version=$(npm --version)
    echo "Node: ${nvm_version} / npm: ${npm_version}"
    process_list "${npm_list_cmd}" "npm.${nvm_version}"
  done
else
  process_list "${npm_list_cmd}" "npm"
fi

# VSCode extensions
vscode_list_cmd="code --list-extensions"
process_list "${vscode_list_cmd}" "vscode"

# Python packages
pip_list_cmd="python3 -m pip list --format freeze"
process_list "${pip_list_cmd}" "pip3"

# Ruby gems
gem_list_cmd="gem list --no-verbose"
process_list "${gem_list_cmd}" "gem"
