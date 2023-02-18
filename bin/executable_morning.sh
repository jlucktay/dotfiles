#!/usr/bin/env bash
set -euo pipefail

# Boilerplate to bring in library script(s).
script_directory="$(cd "$(dirname "${BASH_SOURCE[-1]}")" &> /dev/null && pwd)"
readonly script_directory

for lib in "$script_directory"/lib/*.sh; do
  # shellcheck disable=SC1090
  source "$lib"
done

# The real Dark Souls starts here.
dslog "start"
trap 'dslog "finish"' 0

tool_check limactl topgrade

# Refresh GitHub/OVO SSO for the day.
open https://github.com/orgs/ovotech/teams/ovodevex/members

# For Docker.
limactl start

topgrade
