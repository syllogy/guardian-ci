#!/usr/bin/env bash
set -euo pipefail

if [ -z "${ENV_NAME:-}" ]; then
  echo "Must provide ENV_NAME environment variable"
  exit 1
fi

if [ -z "${SERVICE:-}" ]; then
  echo "Must provide SERVICE environment variable"
  exit 1
fi

if [ -z "${AWS_PROFILE:-}" ]; then
  echo "Must provide AWS_PROFILE environment variable"
  exit 1
fi

VERSION=$(cat ../VERSION)
if [ -n "${USE_VERSION_SHA:-}" ]; then
  VERSION="$VERSION-${CIRCLE_SHA1:-}"
fi

export TF_VAR_app_version="$VERSION" \
  TF_VAR_env="$ENV_NAME" \
  TF_VAR_aws_profile="$AWS_PROFILE"

aws ssm get-parameter --name "/cast/${ENV_NAME}/vars/${SERVICE}" --query 'Parameter.Value' --output text > vars.auto.tfvars
terraform apply --var "aws_profile=$AWS_PROFILE" --auto-approve
