#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob globstar
IFS=$'\n\t'

if [ "$#" -ne 1 ]; then
  echo "Illegal number of parameters; please provide an AWS account name prefix, e.g.: 'cr-'"
  exit 1
fi

if ! command -v aws > /dev/null; then
  echo "'aws' not found! Please install: https://aws.amazon.com/cli/"
  exit 1
fi

if ! command -v awsume > /dev/null; then
  echo "'awsume' not found! Please install: https://github.com/trek10inc/awsume"
  exit 1
fi

if ! command -v jq > /dev/null; then
  echo "'jq' not found! Please install: https://stedolan.github.io/jq/download/"
  exit 1
fi

echo "Account,Region,EC2Count"

awsume_output="$(awsume --list | grep "^$1")"

for ao_line in $awsume_output; do
  IFS=$' \t' read -ra account_line <<< "$ao_line"
  eval "$(awsume -s "${account_line[0]}" 2> /dev/null)"

  for region in $(awsregions); do
    jq_result="$(aws ec2 describe-instances --region "$region" --filter "Name=instance-state-name,Values=running" \
      | jq '.Reservations[].Instances[].InstanceId' | wc -l)"

    if ((jq_result > 0)); then
      echo "${account_line[0]},$region,$jq_result"
    fi
  done
done
