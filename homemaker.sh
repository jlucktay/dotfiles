#!/usr/bin/env bash
# Thank you: https://github.com/anordal/shellharden/blob/master/how_to_do_things_safely_in_bash.md#how-to-begin-a-bash-script
if test "$BASH" = "" || "$BASH" -uc "a=();true \"\${a[@]}\"" 2>/dev/null; then
    # Bash 4.4, Zsh
    set -euo pipefail
else
    # Bash 4.3 and older chokes on empty arrays with set -u.
    set -eo pipefail
fi
shopt -s nullglob globstar
IFS=$'\n\t'

ScriptDirectory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
HomemakerTask=${1:-"default"}
HomemakerCommand="homemaker"

if [ "$HomemakerTask" == "git" ]; then
    HomemakerCommand="$HomemakerCommand --clobber"
fi

eval "$HomemakerCommand" --task="$HomemakerTask" --verbose config.toml "$ScriptDirectory"
