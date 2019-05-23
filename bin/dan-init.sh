#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

SubscriptionClzid=""
TargetSubscription=""

while getopts "s:" Option; do
    case "$Option" in
        s) SubscriptionClzid=$OPTARG ; echo "The '$SubscriptionClzid' CLZID will be used" ;;
        *) echo "Only '-s' is implemented; please provide a CLZID" && exit 1
    esac
done

shopt -s nocasematch

case $SubscriptionClzid in
    CSS000001) TargetSubscription="90ca8d68-d24b-4ec3-bf67-d77c59897abe" ;; # CentralServices
    CSS000004) TargetSubscription="a069efd3-76b7-49b5-a71f-f38dc1956b83" ;; # VdcManagement
    CSS000005) TargetSubscription="b6aa6248-2c28-4a4b-8edb-8ba8573dcace" ;; # VdcSharedInfra
    HUB000001) TargetSubscription="c86c06b1-b8fd-42cd-9a41-68c09d497dad" ;; # HubNetworks
    VDC000001) TargetSubscription="9c226307-2652-4124-a9b5-f59e312a9341" ;; # AppArea
    VDC000003) TargetSubscription="5e813cbb-34d3-43e6-95a6-887fb638adb5" ;; # AppAreaNonProd
    VDC000005) TargetSubscription="174ef5a6-360b-4585-8779-3fac80dbe009" ;; # AppAreaSandbox
    *) echo "'$SubscriptionClzid' isn't a valid CLZID; specify with -s" && exit 2
esac

# We might need to use JQ later; make sure it's present
if ! command -v jq > /dev/null; then
    echo "'jq' not found! Please install: https://stedolan.github.io/jq/download/"
    exit 3
fi

# Key; file location within the storage account
DesiredStateKey="dantfstate.$(basename "$(realpath ..)").$(basename "$(pwd)")"

# Before initialising anything else, we need to check for (and possibly remove) an existing Terraform directory
CurrentStateKey=""

if [ -d ".terraform" ]; then
    if [ -f ".terraform/terraform.tfstate" ]; then
        CurrentStateKey="$(jq -r '.backend.config.key' .terraform/terraform.tfstate)"
    else
        echo "No local 'terraform.tfstate' file found."
    fi

    # Only remove if the current initialised state doesn't line up
    if [ "$DesiredStateKey" != "$CurrentStateKey" ] && [ "$CurrentStateKey" != "" ]; then
        echo -n "Removing old 'terraform init' files... "
        find .terraform -type d -not -path .terraform -not -iname "plugins" -exec rm -rfv -- {} +
        rm -fv .terraform/terraform.tfstate
        echo "done."
    fi
fi

# Storage account where state files are kept
StorageAccount="azeuw1azuredevopstfstate"

# Access key; enables programmatic access to the storage account
echo -n "Switching subscriptions... "
az account set --subscription=a069efd3-76b7-49b5-a71f-f38dc1956b83
echo "done."

echo -n "Retrieving storage account key... "
AccessKey=$(az storage account keys list --account-name $StorageAccount --query "[?keyName == 'key2'].value | [0]")
echo "done."

# Switch subscriptions to given target
echo -n "Switching subscriptions again... "
az account set --subscription="$TargetSubscription"
echo "done."

# Announce init
echo "Initialising Terraform with following dynamic values:"
# printf '\taccess_key:\t%s\n' "$AccessKey"
printf '\tcontainer_name:\t\t%s\n' "$TargetSubscription" # Container name matches target sub GUID
printf '\tkey:\t\t\t%s\n' "$DesiredStateKey"
printf '\tstorage_account:\t%s\n' "$StorageAccount"

# Run the initialisation
terraform init \
    -backend-config="access_key=$AccessKey" \
    -backend-config="container_name=$TargetSubscription" \
    -backend-config="key=$DesiredStateKey" \
    -backend-config="storage_account_name=$StorageAccount"
