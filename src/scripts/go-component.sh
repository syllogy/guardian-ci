#!/usr/bin/env bash
set -euo pipefail

PAT='*\.(md|tf|js|py|svg|png)$|VERSION'
PACKAGE="${PACKAGE:-}"
SKIP="${SKIP:-}"
DEBUG="${DEBUG:-}"
GINKGO="${GINKGO:-ginkgo}"

debug() {
    if [[ -n "$DEBUG" ]]; then
        printf "[DEBUG] %s\n" "$*" 1>&2
    fi
}

run_ginkgo() {
    echo "${GINKGO} -r --randomizeAllSpecs --randomizeSuites --failOnPending --trace --race --progress " "$@"
    eval "${GINKGO}" -r --randomizeAllSpecs --randomizeSuites --failOnPending --trace --race --progress "$@"
}

run_component_tests() {
    set +o pipefail

    if ! (git diff --name-only HEAD HEAD~1 | grep -vE "${PAT}" > /dev/null ); then
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
    # Show inputs
    debug "SKIP=${SKIP}"
    debug "PACKAGE=${PACKAGE}"
    debug "GINKGO=${GINKGO}"

    run_component_tests
fi
