#!/usr/bin/env bash
# Need these specific options set so that when 'find' hits directories with
# permission errors, it doesn't send a non-zero exit code back to 'homemaker'
set +e -u
IFS=$'\n\t'

ScriptDirectory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# shellcheck source=/dev/null
. "$(realpath "$ScriptDirectory/func.processList.sh")"

Now=$(date +%Y%m%d.%H%M%S.%N%z)

GitListCmd="find \"$HOME\" -type d -name \".git\" \
    -not -path \"*/.terraform/*\" -not -path \"*/go/pkg/dep/sources/*\" \
    -execdir pwd \\; 2>/dev/null | sort -f"
GitList=$(realpath "$ScriptDirectory/../../list.git.txt")
GitListArchive=$(realpath "$ScriptDirectory/../../list.git.$Now.txt")

processList "$Now" "$GitListCmd" "$GitList" "$GitListArchive"
