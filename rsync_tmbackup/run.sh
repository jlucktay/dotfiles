#!/usr/bin/env bash

ScriptDirectory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

rsync_tmbackup.sh /Users/jameslucktaylor /Volumes/Sgte-ExFAT/home "${ScriptDirectory}/exclude.txt"
