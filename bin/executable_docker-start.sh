#!/usr/bin/env bash
set -euo pipefail

open --background -a Docker

until docker system info &> /dev/null; do
	sleep 1
done
