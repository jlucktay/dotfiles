#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ScriptDirectory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
HomemakerTask=${1:-"default"}
ExtraArguments=""

if [ "$HomemakerTask" == "git" ]; then
    ExtraArguments="--clobber"
fi

homemaker $ExtraArguments --task="$HomemakerTask" --verbose config.toml "$ScriptDirectory"
