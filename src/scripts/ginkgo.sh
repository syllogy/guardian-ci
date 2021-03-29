#!/usr/bin/env bash
set -euo pipefail

PAT='*\.(md|tf|js|py|svg|png)$|VERSION|.circleci/config.yml'

run_ginkgo() {
    ginkgo -r --randomizeAllSpecs --randomizeSuites "$@"
}

PACKAGE="${PACKAGE:-}"
SKIP="${SKIP:-}"

set +o pipefail
if (git diff --name-only HEAD~1 | grep -cvE "${PAT}" >/dev/null); then
    echo "Nothing to test"
    exit 0
fi
set -o pipefail

test -z "${SKIP}" && run_ginkgo "${PACKAGE}"
test ! -z "${SKIP}" && run_ginkgo --skipPackage "${SKIP}" "${PACKAGE}"
