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

if command -v op &> /dev/null; then
  dslog "🟡 Retrieving GitHub token from 1Password..."

  if ! ght=$(op read "op://Personal/5sgl3dph3g562vhmxhkatrdumu/credential" --account my.1password.com); then
    err "🛑 1Password CLI could not read GitHub token"
  fi

  dslog "✅ Got GitHub token from 1Password OK"

  export GITHUB_TOKEN=$ght
fi

declare -a command_queue=()

# Do some notification cleanup, if there's a token ginsu can use.
# Get it teed up before the GitHub commands are added to the queue.
if [[ -n ${GITHUB_TOKEN:-} ]]; then
  command_queue+=("ginsu --owner-allowlist='ovotech'")
fi

if command -v gdate &> /dev/null; then
  #
  mlb_next_season_start='2025-03-18'
  #

  mlb_epoch=$(gdate --date="$mlb_next_season_start" +%s)

  date_today=$(gdate '+%Y/%m/%d')
  today_epoch=$(gdate --date="$date_today" +%s)

  mlb_season_has_started=$(("$today_epoch" - "$mlb_epoch"))

  if [[ $mlb_season_has_started -ge 0 ]]; then
    command_queue+=(
      # Check the schedules for MLB.TV.
      "open_ff:personal 'https://www.mlb.com/live-stream-games'"
    )
  fi
fi

command_queue+=(
  # Refresh GitHub/OVO SSO for the day.
  "open_ff:ovo 'https://github.com/orgs/ovotech/teams/developer-platforms/members'"

  # Check PR mentions.
  "open_ff:ovo 'https://github.com/notifications?query=reason%3Amention'"

  # Update all of the things.
  topgrade
)

if check_rd_vm; then
  dslog "✅ Rancher Desktop VM check OK"
else
  dslog "🟡 Rancher Desktop VM check did not pass; queueing maintenance pruning commands"

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
)

rdu_logfile="$HOME"/Library/Logs/rancher-desktop/update.log

if [[ -r $rdu_logfile ]]; then
  rdu_lines=$(wc -l < "$rdu_logfile" | xargs)
  rdu_range="$((rdu_lines < 10 ? 0 : rdu_lines - 10)):$rdu_lines"

  command_queue+=(
    # Check for any pending updates to RD; requires a restart of the app and its VM.
    "bat --line-range=\"$rdu_range\" --paging=never --style=plain $rdu_logfile"
  )
fi

tool_check "${command_queue[@]}"

for cq in "${command_queue[@]}"; do
  dslog "$cq"
  eval "$cq"
done
