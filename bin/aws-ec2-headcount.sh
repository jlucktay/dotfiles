#!/usr/bin/env bash
set -euo pipefail
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

AwsumeOutput="$(awsume --list | grep "^$1")"

for AOLine in $AwsumeOutput; do
    IFS=$' \t' read -ra AccountLine <<< "$AOLine"
    eval "$(awsume -s "${AccountLine[0]}" 2>/dev/null)"

    for Region in $(awsregions); do
        JqResult="$(aws ec2 describe-instances --region "$Region" --filter "Name=instance-state-name,Values=running" |
            jq '.Reservations[].Instances[].InstanceId' | wc -l)"

        if (( JqResult > 0 )); then
            echo "${AccountLine[0]},$Region,$JqResult"
        fi
    done
done
