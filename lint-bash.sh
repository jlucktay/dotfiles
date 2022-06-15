#!/usr/bin/env bash
set -euo pipefail

### NOTES
# Linters called by this script are (where possible) configured to follow Google's shell style guide:
# https://google.github.io/styleguide/shell.xml

script_dir="$(cd "$(dirname "${BASH_SOURCE[-1]}")" &> /dev/null && pwd)"

# When calling 'find', some Bash scripts that aren't mine are excluded.
find_scripts=$(
  find -x "$script_dir" \
    -type d -name test_helper -prune -or \
    -type f -name "dot_fzf.bash" -or \
    -type f -name "git-completion.bash" -or \
    -type f -name "posh-git-prompt.sh" -or \
    -type f -iname "*sh" -print
)

mapfile -t script_files <<< "$find_scripts"

# Roll up flags for some linters, as there are quite a few.
shfmt_flags=(
  "--binary-next-line"
  "--case-indent"
  "--indent=2"
  "--simplify"
  "--space-redirects"
  "--write"
)

shellcheck_flags=(
  "--enable=all"
  "--external-sources"
  "--severity=style"
  "--shell=bash"

  # Awaiting https://github.com/anordal/shellharden/issues/43 to stop excluding SC2250, as they conflict.
  "--exclude=SC2250"
)

for script_file in "${script_files[@]}"; do
  # https://github.com/mvdan/sh
  shfmt "${shfmt_flags[@]}" -- "$script_file"

  # https://github.com/anordal/shellharden
  shellharden --check --replace -- "$script_file"

  # https://github.com/koalaman/shellcheck
  shellcheck "${shellcheck_flags[@]}" -- "$script_file"
done
