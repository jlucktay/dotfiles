#!/usr/bin/env bash

if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
  echo >&2 "${BASH_SOURCE[0]} is not being sourced."
  exit 1
fi

# If the actual usage of the Podman Engine VM's disk is over 80%, sound the alarm.
check_pe_vm() {
  tool_check podman gawk

  local df_raw df_pct pct_compare

  if ! df_raw=$(podman machine ssh -- df --total /var/lib); then
    err "Podman Engine does not seem to be running"
  fi

  df_pct=$(gawk 'END { pct = $5; sub(/%/, "", pct); print pct; }' <<< "$df_raw")
  pct_compare=$(bc --mathlib <<< "$df_pct >= 80")

  if ((pct_compare)); then
    # Actual usage is 80% or higher.
    return 1
  fi
}
