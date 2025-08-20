#!/usr/bin/env bash

if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
  echo >&2 "${BASH_SOURCE[0]} is not being sourced."
  exit 1
fi

# Every time Rancher Desktop stops the VM, it frees up unused space.
# Plenty more interesting discussion here: https://github.com/rancher-sandbox/rancher-desktop/issues/1521
# If the actual usage of the VM's disk is over 80%, sound the alarm.
check_rd_vm() {
  tool_check rdctl gawk

  local df_raw df_pct pct_compare
  df_raw=$(rdctl shell df /var/lib)
  df_pct=$(gawk 'END { pct = $4; sub(/%/, "", pct); print pct; }' <<< "$df_raw")
  pct_compare=$(bc --mathlib <<< "$df_pct >= 80")

  if ((pct_compare)); then
    # Actual usage is 80% or higher.
    return 1
  fi
}
