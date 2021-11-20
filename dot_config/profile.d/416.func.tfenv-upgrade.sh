function tfenv_upgrade() {
  # Look up the latest Terraform version that matches the non-alpha/beta semver pattern on L5.
  local tfenv_list grep_list sort_list latest_tf_ver
  tfenv_list="$(tfenv list-remote)"
  grep_list="$(grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' <<< "$tfenv_list")"
  sort_list="$(gsort --version-sort <<< "$grep_list")"
  latest_tf_ver="$(tail -n 1 <<< "$sort_list")"

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
