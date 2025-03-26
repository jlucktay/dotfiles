#!/usr/bin/env bash

if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
  echo >&2 "${BASH_SOURCE[0]} is not being sourced."
  exit 1
fi

# With multiple Firefox profiles present, simply calling 'open <url>' will shunt everything to a default/primary profile.
# Sometimes we want to be very deliberate about opening a link with a specific profile.
open_ff() {
  local -a open_flags=(
    -a /Applications/Firefox.app
    --new
    --args
    # This profile path is the one I use for my personal accounts.
    --profile "$HOME/Library/Application Support/Firefox/Profiles/osh42oko.default-release"
  )

  open_flags+=("$@")

  open "${open_flags[@]}"
}
