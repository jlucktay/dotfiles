#!/usr/local/bin/bash
set -euo pipefail
IFS=$'\n\t'

open --background -a Docker

until docker system info > /dev/null 2>&1; do
    sleep 1
done
