#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
TASK=${1:-"default"}
homemaker --task="$TASK" --verbose config.toml "$DIR"
