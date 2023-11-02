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

date_today="$(date '+%Y')/"
date_today+="$(date '+%m')/"
date_today+="$(date '+%d')"

#
mlb_next_season_start='2024-03-28'
#

declare -a morning_commands=()

if command -v gdate &> /dev/null; then
  mlb_epoch=$(gdate --date="$mlb_next_season_start" +%s)
  today_epoch=$(gdate --date="$date_today" +%s)
  mlb_season_has_started=$(("$today_epoch" - "$mlb_epoch"))

  if [[ $mlb_season_has_started -ge 0 ]]; then
    morning_commands+=(
      # Check the schedules for MLB.TV and MiLB.TV (Cubs affiliates).
      "open 'https://www.mlb.com/live-stream-games'"
      "open 'https://www.milb.com/live-stream-games/$date_today/all/all/cubs'"
    )
  fi
fi

morning_commands+=(
  # Refresh GitHub/OVO SSO for the day.
  "open 'https://github.com/orgs/ovotech/teams/ovodevex/members'"

  # Check PR review requests.
  "open 'https://github.com/notifications?query=reason%3Areview-requested'"

  # Update all of the things.
  topgrade
)

tool_check "${morning_commands[@]}"

for mc in "${morning_commands[@]}"; do
  dslog "$mc"
  eval "$mc"
done
