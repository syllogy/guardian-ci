#!/usr/bin/env bash
set -euo pipefail

TERRAFORM="${TERRAFORM:-terraform}"
TF_MODULE_DIR="${TF_MODULE_DIR:-~/terraform-modules}"

vet_terraform () {
  eval "${TERRAFORM}" fmt --check . || (echo "Terraform is not formatted correctly. Please run 'terraform fmt'" && exit 1)

  latest_module_version="v$(cat "${TF_MODULE_DIR}"/VERSION)"

  tf_versions=$(grep -E 'source\s+=\s+.*bishopfox.*v[0-9\.]*' ./*.tf | grep -oE 'v[0-9\.]+')

  if [[ -n $tf_versions ]]; then
  echo "$tf_versions" | while read -r version; do
    if [[ "$latest_module_version" != "$version" ]]; then
    echo "terraform modules can be upgraded from $version to $latest_module_version"
    echo "if it cannot be upgraded, remove this job from the pipeline and re-add it when modules can be upgraded"
    exit 1
    fi
  done
  fi
}

TEST_ENV="bats-core"
if [ "${0#*$TEST_ENV}" == "$0" ]; then
  vet_terraform
fi
