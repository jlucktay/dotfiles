#!/usr/bin/env bash
set -euo pipefail

# aws ec2 describe-instances --filters "Name=tag:Owner,Values=james.lucktaylor"

while IFS= read -r line; do
	#   echo "role: '$line'"
	echo "aws iam delete-role --role-name $line"
done < "$HOME/roles.head.txt"
