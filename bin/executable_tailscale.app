#!/usr/bin/env bash
set -euo pipefail

process_command_lines=$(ps -xo comm)
tailscale_bin_path=$(grep 'MacOS/Tailscale$' <<< "$process_command_lines")

exec $tailscale_bin_path "$@"
