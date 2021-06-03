#!/usr/bin/env bash
set -euo pipefail

# Linters called by this script are (where possible) configured to follow Google's shell style guide:
# https://google.github.io/styleguide/shell.xml

script_dir="$(cd "$(dirname "${BASH_SOURCE[-1]}")" &> /dev/null && pwd)"

sh_files=()
dirty_files=()

# When calling 'find', some scripts that aren't mine are excluded.
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

# https://github.com/koalaman/shellcheck
# Exclude: https://www.shellcheck.net/wiki/SC2250
# Prefer putting braces around variable references even when not strictly required.
for sh_file in "${sh_files[@]}"; do
  shellcheck --enable=all --exclude=SC2250 --severity=style --shell=bash --external-sources -- "$sh_file"
done

# https://github.com/mvdan/sh
for sh_file in "${sh_files[@]}"; do
  if ! shfmt -w -d -s -ln=bash -i=2 -bn -ci -sr "$sh_file" &> /dev/null; then
    dirty_files+=("$sh_file")
  fi
done

# https://github.com/anordal/shellharden
shellharden_count=0

for sh_file in "${sh_files[@]}"; do
  if ! shellharden --check -- "$sh_file" &> /dev/null; then
    already_dirty=0

    for dirty_file in "${dirty_files[@]}"; do
      if [ "$dirty_file" == "$sh_file" ]; then
        already_dirty=1
      fi
    done

    if ((already_dirty == 0)); then
      ((++shellharden_count))
      echo "Applying shellharden replacements to '$sh_file'..."
    fi

    shellharden --replace -- "$sh_file"
  fi
done

if ((shellharden_count > 0)); then
  exit "$shellharden_count"
fi
