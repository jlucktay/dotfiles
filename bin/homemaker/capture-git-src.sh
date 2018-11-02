#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
find "$HOME" -type d -name ".git" \
    -not -path "*.terraform*" -not -path "*go/pkg/dep/sources*" \
    -execdir pwd \; 2>/dev/null | sort -f > "$DIR/../../src.git.txt"
