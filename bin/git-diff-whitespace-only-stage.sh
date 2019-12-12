#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob globstar
IFS=$'\n\t'

while read -r diff_file; do
  diff_without_whitespace=$(git diff -w -U0 --word-diff-regex=[^[:space:]] "$diff_file")

  if test -z "$diff_without_whitespace"; then
    git add "$diff_file"
  fi
done < <(git diff --name-only --relative)
