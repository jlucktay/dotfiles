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

DEFAULT=NO

for i in "$@"; do
    case $i in
        -e=*|--extension=*)
            EXTENSION="${i#*=}"
            shift   # past argument=value
            ;;
        -s=*|--searchpath=*)
            SEARCHPATH="${i#*=}"
            shift   # past argument=value
            ;;
        -l=*|--lib=*)
            LIBPATH="${i#*=}"
            shift   # past argument=value
            ;;
        --default)
            DEFAULT=YES
            shift   # past argument with no value
            ;;
        *)
                    # unknown option
            ;;
    esac
done

echo "FILE EXTENSION  = ${EXTENSION}"
echo "SEARCH PATH     = ${SEARCHPATH}"
echo "LIBRARY PATH    = ${LIBPATH}"
echo "DEFAULT         = ${DEFAULT}"
echo "Number files in SEARCH PATH with EXTENSION: $(find ${SEARCHPATH}/ -maxdepth 1 -iname "*.${EXTENSION}" -not -type d | wc -l)"

if [[ -n $1 ]]; then
    echo "Last line of file specified as non-opt/last argument:"
    tail -1 "$1"
fi

# demo:
# $ command-line-arguments.sh -e=conf -s=/etc -l=/usr/lib /etc/hosts
