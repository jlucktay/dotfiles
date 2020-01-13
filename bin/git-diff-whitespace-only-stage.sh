#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob globstar
IFS=$'\n\t'

while read -r diff_file; do
  if stat "$diff_file" &> /dev/null; then
    diff_without_whitespace=$(
      git diff \
        --ignore-all-space \
        --ignore-blank-lines \
        --unified=0 \
        --word-diff-regex=[^[:space:]] \
        "$diff_file"
    )
    if test -z "$diff_without_whitespace"; then
      git add "$diff_file"
    fi
  else
    git rm "$diff_file"
  fi
done < <(git diff --name-only --relative)
