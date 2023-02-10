#!/usr/bin/env bash
set -euo pipefail

script_name=$(basename "${BASH_SOURCE[0]}")

# Check for presence of required tools.
command -v brew &> /dev/null || {
  echo >&2 "$script_name: Homebrew has not been installed: https://brew.sh"
  exit 1
}

command -v docker &> /dev/null || {
  echo >&2 "$script_name: Docker has not been installed via Homebrew: https://formulae.brew.sh/cask/docker"
  exit 1
}

test -d "${package_manager_prefix:?}/Cellar/coreutils" || {
  echo >&2 "$script_name: 'coreutils' has not been installed via Homebrew: https://formulae.brew.sh/formula/coreutils"
  exit 1
}

# Setup log, and run cleanups.
cron_log_dir="$HOME/log"
mkdir -p "$cron_log_dir"
cron_log="$cron_log_dir/cron.$(gdn).log"

{
  echo "--- 'brew cleanup'"
  brew cleanup
} &>> "$cron_log"

dsi_exit=0
docker system info &> /dev/null || dsi_exit=$?

if [[ $dsi_exit -ne 0 ]]; then
  {
    echo
    echo "xxx Docker isn't running; can't prune."
  } &>> "$cron_log"

  exit
fi

{
  echo "--- 'docker system prune --force'"
  docker system prune --force
} &>> "$cron_log"
