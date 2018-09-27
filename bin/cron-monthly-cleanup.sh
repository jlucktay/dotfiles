#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

CronLog="/Users/jameslucktaylor/log/cron.$(gdate '+%Y%m%d.%H%M%S.%N%z').log"

echo "--- brew cleanup" >> "$CronLog"
brew cleanup >> "$CronLog" 2>&1

open --background -a Docker
while ! docker system info > /dev/null 2>&1; do
    sleep 1
done

echo "--- docker system prune --all --force" >> "$CronLog"
docker system prune --all --force >> "$CronLog" 2>&1
