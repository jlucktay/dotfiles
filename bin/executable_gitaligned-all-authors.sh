#!/usr/bin/env bash
set -euo pipefail

for i in ./*; do
  cd "$i" &> /dev/null || continue

  git shortlog --numbered --summary | cut -f2- | while read -r u; do
    gitaligned -u "$u"
  done | grep "^Author" | sed "s~$~ in ${i:2}~"

  cd - &> /dev/null
done | sort
