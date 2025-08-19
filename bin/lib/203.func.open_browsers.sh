#!/usr/bin/env bash

if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
  echo >&2 "${BASH_SOURCE[0]} is not being sourced."
  exit 1
fi

# With multiple browsers present, simply calling 'open <url>' will shunt everything to a default.
# Sometimes we want to be very deliberate about opening a link with a specific browser.

open_chrome() {
  open -a "Google Chrome" "$@"
}

open_firefox() {
  open -a Firefox --new --args "$@"
}
