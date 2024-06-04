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
      # Check the schedules for MLB.TV.
      "open 'https://www.mlb.com/live-stream-games'"
    )
  fi
fi

morning_commands+=(
  # Refresh GitHub/OVO SSO for the day.
  "open 'https://github.com/orgs/ovotech/teams/dev-platforms-team-red/members'"

  # Check PR review requests.
  "open 'https://github.com/notifications?query=reason%3Areview-requested'"

  # Update all of the things.
  topgrade
)

if check_rd_vm; then
  dslog "Rancher Desktop VM check ✅ OK"

  morning_commands+=(
    # Check for any pending updates; requires a restart of the Rancher Desktop app and VM.
    "tail -n 2 \"$HOME\"/Library/Logs/rancher-desktop/update.log"
  )
else
  dslog "Rancher Desktop VM check 🛑 did not pass"

  morning_commands+=(
    # Remove all build cache more than 30 days old, without confirmation.
    "docker buildx prune --all --filter=\"until=$((30 * 24))h\" --force --verbose"

    # Remove dangling images more than 30 days old.
    "docker system prune --filter=\"until=$((30 * 24))h\" --force"

    # Remove anonymous volumes.
    "docker volume prune --force"
  )
fi

morning_commands+=(
  # See what's on.
  "cineworld -l 3"
)

tool_check "${morning_commands[@]}"

for mc in "${morning_commands[@]}"; do
  dslog "$mc"
  eval "$mc"
done
