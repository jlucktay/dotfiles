#!/usr/bin/env bash

if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
  echo >&2 "${BASH_SOURCE[0]} is not being sourced."
  exit 1
fi

tfenv_upgrade() {
  local -
  set -o pipefail

  # Look up the latest Terraform version that matches the non-alpha/beta semver pattern on L5.
  local latest_tf_ver
  latest_tf_ver="$(tfenv list-remote | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | sort --version-sort | tail -n 1)"

  # Uninstall the current Terraform version, if one is currently installed.
  # Note that every time tfenv itself is upgraded to a new version, it loses any installed Terraform version(s).
  local tfenv_current
  if tfenv_current="$(tfenv version-name)"; then
    tfenv uninstall "$tfenv_current"
  fi

  # Install the latest Terraform version we looked up earlier.
  tfenv install "$latest_tf_ver"
  tfenv use "$latest_tf_ver"
}
