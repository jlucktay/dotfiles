#!/usr/bin/env bash

if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
  echo >&2 "${BASH_SOURCE[0]} is not being sourced."
  exit 1
fi

# With multiple Firefox profiles present, simply calling 'open <url>' will shunt everything to a default/primary profile.
# Sometimes we want to be very deliberate about opening a link with a specific profile.

# This function will initialise the array passed to it (via a nameref) with some common denominator values.
# Thank you: https://stackoverflow.com/a/49971213
open_ff:internal() {
  local -n arg_one=$1

  # shellcheck disable=SC2034
  arg_one=(
    -a /Applications/Firefox.app
    --new
    --args
  )
}

open_ff:personal() {
  local -a open_flags

  open_ff:internal open_flags

  open_flags+=(
    # This profile path is the one I use for my personal accounts.
    --profile "$HOME/Library/Application Support/Firefox/Profiles/osh42oko.default-release"
  )

  open "${open_flags[@]}"
}

open_ff:ovo() {
  local -a open_flags

  open_ff:internal open_flags

  open_flags+=(
    # This profile path is the one I use for my work accounts at OVO.
    --profile "$HOME/Library/Application Support/Firefox/Profiles/wkzra9g8.james.lucktaylor@ovo.com"
  )

  open "${open_flags[@]}"
}
