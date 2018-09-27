#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# todo: roll through all regions with $(awsregions) and '--region'
aws ec2 describe-instances --filters "Name=tag:Owner,Values=james.lucktaylor" |
    jq '.Reservations[].Instances[] |
        {
            n: (.Tags[] | select(.Key == "Name") | .Value),
            id: .InstanceId,
            az: .Placement.AvailabilityZone,
            ip: .PublicIpAddress,
            up: .State.Name
        }'
