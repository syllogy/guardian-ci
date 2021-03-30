#!/usr/bin/env bash
set -euo pipefail

TERRAFORM="${TERRAFORM:-terraform}"
TF_MODULE_DIR="${TF_MODULE_DIR:-~/terraform-modules}"
MODULE_PAT='source\s+=\s+.*bishopfox.*v[0-9\.]*'

find_modules () {
 find . -type f -print0 -name '*.tf' \
    | xargs -0 grep -E "${MODULE_PAT}" 
}

vet_terraform () {
  eval "${TERRAFORM}" fmt --check . || (echo "Terraform is not formatted correctly. Please run 'terraform fmt'" && exit 1)

  latest_module_version="v$(cat "${TF_MODULE_DIR}"/VERSION)"

  if ! (find_modules >/dev/null); then
    echo "no modules found"
    exit 0
  fi

  tf_versions=$(find_modules | grep -oE 'v[0-9\.]+')

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
