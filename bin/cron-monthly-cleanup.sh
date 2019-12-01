#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

script_name=$( basename "${BASH_SOURCE[-1]}" )
cron_log_dir="$HOME/log"

# Check for presence of other variables/tools
command -v brew &>/dev/null || {
    echo >&2: "$script_name: Homebrew has not been installed: https://brew.sh"
    exit 1
}

command -v docker &>/dev/null || {
    echo >&2: "$script_name: Docker has not been installed via Homebrew: https://formulae.brew.sh/cask/docker"
    exit 1
}

test -d /usr/local/Cellar/coreutils || {
    echo >&2 "$script_name: 'coreutils' has not been installed via Homebrew: https://formulae.brew.sh/formula/coreutils"
    exit 1
}

# Setup log and run cleanups
gmkdir -pv "$cron_log_dir"
cron_log="$cron_log_dir/cron.$( gdate '+%Y%m%d.%H%M%S.%N%z' ).log"

{
    echo "--- 'brew cleanup'"
    brew cleanup
} &>> "$cron_log"

{
    echo "--- Starting Docker..."
    open --background -a Docker
} >> "$cron_log"

until docker system info &> /dev/null; do
    sleep 0.1s
done

{
    echo "--- 'docker system prune --all --force'"
    docker system prune --all --force
} &>> "$cron_log"
