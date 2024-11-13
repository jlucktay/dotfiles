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
mlb_next_season_start='2025-03-18'
#

declare -a command_queue=()

# Do some notification cleanup, if the tool is available and there's a token it can use.
# Get it teed up before the GitHub commands are added to the queue.
if command -v ginsu &> /dev/null && [[ -v GITHUB_TOKEN ]]; then
  command_queue+=("ginsu --owner-allowlist='ovotech'")
fi

if command -v gdate &> /dev/null; then
  mlb_epoch=$(gdate --date="$mlb_next_season_start" +%s)
  today_epoch=$(gdate --date="$date_today" +%s)
  mlb_season_has_started=$(("$today_epoch" - "$mlb_epoch"))

  if [[ $mlb_season_has_started -ge 0 ]]; then
    command_queue+=(
      # Check the schedules for MLB.TV.
      "open 'https://www.mlb.com/live-stream-games'"
    )
  fi
fi

command_queue+=(
  # Refresh GitHub/OVO SSO for the day.
  "open 'https://github.com/orgs/ovotech/teams/dev-platforms-team-red/members'"

  # Check PR mentions.
  "open 'https://github.com/notifications?query=reason%3Amention'"

  # Update all of the things.
  topgrade
)

if check_rd_vm; then
  dslog "Rancher Desktop VM check ✅ OK"
else
  dslog "Rancher Desktop VM check 🛑 did not pass"

  command_queue+=(
    # Remove all build cache more than 30 days old, without confirmation.
    "docker buildx prune --all --filter=\"until=$((30 * 24))h\" --force --verbose"

    # Remove dangling images more than 30 days old.
    "docker system prune --filter=\"until=$((30 * 24))h\" --force"

    # Remove anonymous volumes.
    "docker volume prune --force"
  )
fi

command_queue+=(
  # See what's on.
  "cineworld -l 3"

  # Check for any pending updates to RD; requires a restart of the app and its VM.
  "tail -n 3 \"$HOME\"/Library/Logs/rancher-desktop/update.log"
)

tool_check "${command_queue[@]}"

for cq in "${command_queue[@]}"; do
  dslog "$cq"
  eval "$cq"
done
