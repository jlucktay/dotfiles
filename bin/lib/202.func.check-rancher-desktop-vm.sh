#!/usr/bin/env bash

if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
  echo >&2 "${BASH_SOURCE[0]} is not being sourced."
  exit 1
fi

# Every time Rancher Desktop stops the VM, it frees up unused space.
# The 'diffdisk' file's apparent size will show as larger than its total disk usage size.
# If the actual usage of the VM's diffdisk file is over 80%, sound the alarm.
check_rd_vm() {
  tool_check gstat bc

  stat_file="$HOME/Library/Application Support/rancher-desktop/lima/0/diffdisk"

  if [[ ! -r $stat_file ]] || ! blocks_allocated=$(gstat --format='%b' "$stat_file" 2> /dev/null); then
    echo >&2 "File '$stat_file' not found."
    return 0
  fi

  block_size=$(gstat --format='%B' "$stat_file")
  apparent_size=$((blocks_allocated * block_size))
  total_size=$(gstat --format='%s' "$stat_file")
  pct_apparent_total=$(echo "$apparent_size / $total_size" | bc --mathlib)
  pct_compare=$(echo "$pct_apparent_total >= 0.8" | bc --mathlib)

  if ((pct_compare)); then
    # Actual usage is 80% or higher.
    return 1
  fi
}
