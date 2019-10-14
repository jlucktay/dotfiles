#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ScriptDirectory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

Flags=$(rsync_tmbackup.sh --rsync-get-flags)
Flags+=" --no-devices --no-specials"

TimeStart=$(gdate +%s%N)

rsync_tmbackup.sh \
    --rsync-set-flags "$Flags" \
    /Users/jameslucktaylor \
    /Volumes/Sgte-ExFAT/home \
    "${ScriptDirectory}/exclude.txt"

TimeTaken=$((($(gdate +%s%N) - TimeStart)/1000000))
echo "Time taken: ${TimeTaken}ms"
