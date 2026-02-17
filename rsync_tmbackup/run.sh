#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[-1]}")" &> /dev/null && pwd)"

flags=$(rsync_tmbackup.sh --rsync-get-flags)
flags+=" --no-devices --no-specials"

time_start=$(gdate +%s%N)

rsync_tmbackup.sh \
	--rsync-set-flags "$flags" \
	"$HOME" \
	/Volumes/Sgte-ExFAT/home \
	"$script_dir/exclude.txt"

time_taken=$((($(gdate +%s%N) - time_start) / 1000000))
echo "Time taken: ${time_taken}ms"
