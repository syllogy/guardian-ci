#!/usr/bin/env bash
set -euo pipefail

PAT='*\.(md|tf|js|py|svg|png)$|VERSION|.circleci/config.yml'
PACKAGE="${PACKAGE:-}"
SKIP="${SKIP:-}"
POSTGRES="${POSTGRES:-}"
POSTGRES_DB="${POSTGRES_DB:-component}"
RABBIT="${RABBIT:-}"
GINKGO="${GINKGO:-ginkgo}"

export POSTGRES_PORT=5432 POSTGRES_USER=component POSTGRES_PASSWORD=component
export RABBIT_URL='amqp://guest:guest@localhost:5672'
export RABBIT_MGMT_URL='http://guest:guest@localhost:15672'

err() {
    echo "$@" >&2
    exit 1
}

run_ginkgo() {
    eval "${GINKGO}" -r --randomizeAllSpecs --randomizeSuites "$@"
}

start_rabbit() {
    # Starts rabbit and applies migrations
    RABBIT_PORT=5672 RABBIT_MGMT_PORT=15672 docker-compose up -d rabbit

    until docker-compose exec rabbit rabbitmqctl await_startup --timeout 60; do
        sleep 1
    done
}

start_postgres() {
    docker-compose up -d postgres

    until docker-compose exec postgres pg_isready; do
        sleep 1
    done

    docker-compose run migrate
}

run_component_tests() {
    set +o pipefail

    if ! (git diff --name-only HEAD~1 | grep -vE "${PAT}" >/dev/null); then
        echo "Nothing to test"
        exit 0
    fi
    set -o pipefail

    if [ -n "${RABBIT}" ]; then
        start_rabbit
    fi


    if [ -n "${POSTGRES}" ]; then
        start_postgres
    fi


    if [ -z "${SKIP}" ]; then
        run_ginkgo "${PACKAGE}"
    else
        run_ginkgo --skipPackage "${SKIP}" "${PACKAGE}"
    fi
}

TEST_ENV="bats-core"
if [ "${0#*$TEST_ENV}" == "$0" ]; then
    run_component_tests
fi
