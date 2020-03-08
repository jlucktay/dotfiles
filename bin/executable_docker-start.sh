#!/usr/bin/env bash
set -euo pipefail
shopt -s globstar nullglob
IFS=$'\n\t'

open --background -a Docker

until docker system info &> /dev/null; do
  sleep 1
done
