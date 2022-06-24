if command -v tfenv &> /dev/null && command -v keybase &> /dev/null; then
  function tfenv_upgrade() {
    local -
    set -o pipefail

    # Look up the latest Terraform version that matches the non-alpha/beta semver pattern on L5.
    local latest_tf_ver
    latest_tf_ver="$(tfenv list-remote | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | gsort --version-sort | tail -n 1)"

    # Start getting Keybase up and running.
    # It will verify the Terraform download later.
    keybase ctl start &> /dev/null &

    # Uninstall the current Terraform version, if one is currently installed.
    # Note that every time tfenv itself is upgraded to a new version, it loses any installed Terraform version(s).
    local tfenv_current
    if tfenv_current="$(tfenv version-name)"; then
      tfenv uninstall "$tfenv_current"
    fi

    # Make sure Keybase is ready to verify the Terraform install.
    sleep 3
    keybase ctl wait

    # Install the latest Terraform version we looked up earlier.
    tfenv install "$latest_tf_ver"
    tfenv use "$latest_tf_ver"

    # Close down Keybase.
    keybase ctl wait
    keybase ctl app-exit

    # Install the upgraded Terraform version's shell completions.
    terraform --install-autocomplete
  }
fi
