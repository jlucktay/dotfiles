#!/usr/bin/env bash
set -euo pipefail

# Boilerplate to bring in library script(s).
script_directory="$(cd "$(dirname "${BASH_SOURCE[-1]}")" &> /dev/null && pwd)"
readonly script_directory

for lib in "$script_directory"/lib/*.sh; do
  # shellcheck disable=SC1090
  source "$lib"
done

# The real Dark Souls starts here.
dslog "start"
trap 'dslog "finish"' 0

declare -a morning_commands=(
  # Check the MLB.TV and MiLB.TV schedules.
  "open 'https://www.mlb.com/live-stream-games'"
  "open 'https://www.milb.com/live-stream-games'"

  # Refresh GitHub/OVO SSO for the day.
  "open 'https://github.com/orgs/ovotech/teams/ovodevex/members'"

  # Update all of the things.
  topgrade
)

tf_od=$(terraform version --json | jq '.terraform_outdated')

if [[ $tf_od == "true" ]]; then
  # Upgrade Terraform if it is out of date.

  # shellcheck disable=SC1091
  source "$HOME/.config/profile.d/416.func.tfenv-upgrade.sh"

  morning_commands+=(tfenv_upgrade)
fi

tool_check "${morning_commands[@]}"

for mc in "${morning_commands[@]}"; do
  dslog "$mc"
  eval "$mc"
done
