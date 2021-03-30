#!/usr/bin/env bash
set -euo pipefail

PAT='*\.(md|tf|js|py|svg|png)$|VERSION|.circleci/config.yml'
PACKAGE="${PACKAGE:-}"
SKIP="${SKIP:-}"
GINKGO="${GINKGO:-ginkgo}"

run_ginkgo() {
    eval "${GINKGO}" -r --randomizeAllSpecs --randomizeSuites "$@"
}

run_unit_tests () {
    set +o pipefail
    if ! (git diff --name-only HEAD HEAD~1 | grep -vE "${PAT}"); then
        echo "Nothing to test"
        exit 0
    fi
    set -o pipefail

    if [ -z "${SKIP}" ]; then
        run_ginkgo "${PACKAGE}"
    else
        run_ginkgo --skipPackage "${SKIP}" "${PACKAGE}"
    fi
}

TEST_ENV="bats-core"
if [ "${0#*$TEST_ENV}" == "$0" ]; then
    run_unit_tests
fi
