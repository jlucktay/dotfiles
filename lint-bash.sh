#!/usr/bin/env bash
set -euo pipefail
shopt -s globstar nullglob

### NOTES
# Linters called by this script are (where possible) configured to follow Google's shell style guide:
# https://google.github.io/styleguide/shell.xml
#
# When calling 'find', some scripts that aren't mine are excluded.

script_dir="$(cd "$(dirname "${BASH_SOURCE[-1]}")" &> /dev/null && pwd)"

sh_files=()
while IFS= read -r -d $'\0' file; do
  sh_files+=("$file")
done < <(
  find -x "$script_dir" -type f -iname "*sh" \
    -not -name "git-completion.bash" \
    -not -name "posh-git-prompt.sh" \
    -not -path "*/.git/*" \
    -print0 \
    | sort --zero-terminated
)

# https://github.com/mvdan/sh
for sh_file in "${sh_files[@]}"; do
  shfmt -w -s -ln=bash -i=2 -bn -ci -sr "$sh_file"
done

# https://github.com/anordal/shellharden
shellharden_count=0

for sh_file in "${sh_files[@]}"; do
  if ! shellharden --check -- "$sh_file" &> /dev/null; then
    ((++shellharden_count))
    echo "Applying shellharden replacements to '$sh_file'..."
    shellharden --replace -- "$sh_file"
  fi
done

if ((shellharden_count > 0)); then
  exit "$shellharden_count"
fi

# https://github.com/koalaman/shellcheck
for sh_file in "${sh_files[@]}"; do
  shellcheck --enable=all --exclude=SC2250 --severity=style --shell=bash --external-sources -- "$sh_file"
done

# Exclude: https://www.shellcheck.net/wiki/SC2250
# Prefer putting braces around variable references even when not strictly required.
