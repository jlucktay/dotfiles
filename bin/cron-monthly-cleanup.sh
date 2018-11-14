#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

CronLogDir="/Users/jameslucktaylor/log"
mkdir -p "$CronLogDir"

CronLog="$CronLogDir/cron.$(gdate '+%Y%m%d.%H%M%S.%N%z').log"

{ echo "--- 'brew cleanup'"; brew cleanup; } >> "$CronLog" 2>&1

{ echo "--- Starting Docker..."; open --background -a Docker; } >> "$CronLog"
until docker system info > /dev/null 2>&1; do
    sleep 0.1s
done

{ echo "--- 'docker system prune --all --force'"; docker system prune --all --force; } >> "$CronLog" 2>&1
