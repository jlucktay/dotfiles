#!/usr/bin/env bash
set -euo pipefail
shopt -s globstar nullglob
IFS=$'\n\t'

default=NO

for i in "$@"; do
  case $i in
    -e=* | --extension=*)
      extension="${i#*=}"
      shift # past argument=value
      ;;
    -s=* | --searchpath=*)
      search_path="${i#*=}"
      shift # past argument=value
      ;;
    -l=* | --lib=*)
      lib_path="${i#*=}"
      shift # past argument=value
      ;;
    --default)
      default=YES
      shift # past argument with no value
      ;;
    *)
      # unknown option
      ;;
  esac
done

echo "File extension                             = $extension"
echo "Search path                                = $search_path"
echo "Library path                               = $lib_path"
echo "Default                                    = $default"
echo "Number files in SEARCH PATH with extension = \
$(find "$search_path/" -maxdepth 1 -iname "*.$extension" -not -type d | wc -l | xargs)"

if [[ -n $1 ]]; then
  echo
  echo "Last line of file specified as non-opt/last argument:"
  tail -1 "$1"
fi

# demo:
# $ command-line-arguments.sh -e=conf -s=/etc -l=/usr/lib /etc/hosts
