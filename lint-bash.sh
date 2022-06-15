#!/usr/bin/env bash
set -euo pipefail

### NOTES
# Linters called by this script are (where possible) configured to follow Google's shell style guide:
# https://google.github.io/styleguide/shell.xml

script_dir="$(cd "$(dirname "${BASH_SOURCE[-1]}")" &> /dev/null && pwd)"

# When calling 'find', some scripts that aren't mine are excluded.
find_scripts=$(
  find -x "${script_dir}" -type f -iname "*sh" \
    -not -name "git-completion.bash" \
    -not -name "posh-git-prompt.sh" \
    -not -path "*/.git/*"
)

mapfile -t script_files <<< "${find_scripts}"

# Roll up flags for 'shfmt', as there are quite a few.
shfmt_flags=(
  "--binary-next-line"
  "--case-indent"
  "--indent=2"
  "--simplify"
  "--space-redirects"
  "--write"
)

for script_file in "${script_files[@]}"; do
  # https://github.com/mvdan/sh
  shfmt "${shfmt_flags[@]}" -- "${script_file}"

  # https://github.com/anordal/shellharden
  shellharden --check --replace -- "${script_file}"

  # https://github.com/koalaman/shellcheck
  shellcheck --enable=all --external-sources --severity=style --shell=bash -- "${script_file}"
done
