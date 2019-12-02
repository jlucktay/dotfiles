#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

if ! command -v aws > /dev/null; then
    echo "'aws' not found! Please install: https://aws.amazon.com/cli/"
    exit 1
fi

if ! command -v jq > /dev/null; then
    echo "'jq' not found! Please install: https://stedolan.github.io/jq/download/"
    exit 1
fi

for Region in $(awsregions); do
    echo -n "Region: $Region... "

    # Attempt to create the Default VPC
    set +e
    AwsCreateOutput="$(aws ec2 create-default-vpc --region "$Region" 2>&1)"
    AwsResult=$?
    set -e

    if [[ $AwsResult -eq 0 ]]; then
        # Successfully created
        VpcId=$(echo "$AwsCreateOutput" | jq '.Vpc.VpcId')
        echo "$VpcId"
    else
        AwsDescribeOutput=$(aws ec2 describe-vpcs --filters Name=isDefault,Values=true --region "$Region")
        VpcId=$(echo "$AwsDescribeOutput" | jq -r '.Vpcs[].VpcId')
        echo "Default VPC '$VpcId' already exists."
    fi

    # (Re)set the Name tag
    echo -n "Setting 'Name' tag on '$VpcId'... "
    aws ec2 create-tags --region "$Region" --resources "$VpcId" --tags Key=Name,Value=Default
    echo "Done."
done
