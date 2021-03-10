#!/usr/bin/env bash
set -euo pipefail

if [ -z "${ENV_NAME:-}" ]; then
  echo "Must provide ENV_NAME environment variable"
  exit 1
fi

STATE_BUCKET=$(aws ssm get-parameter --name "/cast/${ENV_NAME}/state_bucket" --query 'Parameter.Value' --output text)
DYNAMO_TABLE=$(aws ssm get-parameter --name "/cast/${ENV_NAME}/dynamodb_lock_table" --query 'Parameter.Value' --output text)

terraform init \
  -backend-config="bucket=${STATE_BUCKET}" \
  -backend-config="dynamodb_table=${DYNAMO_TABLE}"