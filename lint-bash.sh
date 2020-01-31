#!/usr/bin/env bash
set -euo pipefail
shopt -s globstar nullglob

### NOTES
# Linters called by this script are (where possible) configured to follow Google's shell style guide:
# https://google.github.io/styleguide/shell.xml
#
# When calling 'find', some scripts that aren't mine are excluded.

script_dir="$(cd "$(dirname "${BASH_SOURCE[-1]}")" &> /dev/null && pwd)"

# https://github.com/mvdan/sh
find -x "$script_dir" -type f -iname "*sh" \
  -not -name "git-completion.bash" \
  -not -name "posh-git-prompt.sh" \
  -not -path "*/.git/*" \
  -print0 \
  | xargs -0 -n 1 shfmt -w -s -ln=bash -i=2 -bn -ci -sr

# https://github.com/anordal/shellharden
find -x "$script_dir" -type f -iname "*sh" \
  -not -name "git-completion.bash" \
  -not -name "posh-git-prompt.sh" \
  -not -path "*/.git/*" \
  -print0 \
  | xargs -0 -n 1 shellharden --check --replace --

# https://github.com/koalaman/shellcheck
find -x "$script_dir" -type f -iname "*sh" \
  -not -name "git-completion.bash" \
  -not -name "posh-git-prompt.sh" \
  -not -path "*/.git/*" \
  -print0 \
  | xargs -0 -n 1 shellcheck --enable=all --exclude=SC2250 --severity=style --shell=bash --external-sources --

# Exclude: https://www.shellcheck.net/wiki/SC2250
# Prefer putting braces around variable references even when not strictly required.
