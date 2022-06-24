#!/usr/bin/env bash
set -euo pipefail

default=NO
extension=txt
search_path=.

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
echo "Default                                    = $default"

number_files=$(find "$search_path/" -maxdepth 1 -iname "*.$extension" -not -type d | wc -l | xargs)
echo "Number files in SEARCH PATH with extension = $number_files"

if [[ -n ${1:-} ]]; then
  echo
  echo "Last line of file specified as non-opt/last argument:"
  tail -1 "$1"
fi

# demo:
# $ command-line-arguments.sh -e=conf -s=/etc -l=/usr/lib /etc/hosts
