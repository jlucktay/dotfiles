if command -v tfenv &> /dev/null; then
  function tfenv_upgrade() {
    local -
    set -o pipefail

    # Look up the latest Terraform version that matches the non-alpha/beta semver pattern on L5.
    local latest_tf_ver
    latest_tf_ver="$(tfenv list-remote | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | sort --version-sort | tail -n 1)"

    # Start getting Keybase up and running, if it is installed.
    # It will verify the Terraform download later.
    if command -v keybase &> /dev/null; then
      keybase ctl start &> /dev/null &
    fi

    # Uninstall the current Terraform version, if one is currently installed.
    # Note that every time tfenv itself is upgraded to a new version, it loses any installed Terraform version(s).
    local tfenv_current
    if tfenv_current="$(tfenv version-name)"; then
      tfenv uninstall "$tfenv_current"
    fi

    # Make sure Keybase is ready to verify the Terraform install.
    if command -v keybase &> /dev/null; then
      sleep 3
      keybase ctl wait
    fi

    # Install the latest Terraform version we looked up earlier.
    tfenv install "$latest_tf_ver"
    tfenv use "$latest_tf_ver"

    if command -v keybase &> /dev/null; then
      # Close down Keybase.
      keybase ctl wait
      keybase ctl app-exit
    fi
  }
fi
