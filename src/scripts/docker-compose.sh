#!/usr/bin/env bash
set -euo pipefail

DEBUG="${DEBUG:-}"
POSTGRES="${POSTGRES:-}"
POSTGRES_DB="${POSTGRES_DB:-component}"
RABBIT="${RABBIT:-}"

echo "export RABBIT_URL='amqp://guest:guest@localhost:5672'
export RABBIT_MGMT_URL='http://guest:guest@localhost:15672'
export POSTGRES_PORT=5432 POSTGRES_USER=component POSTGRES_PASSWORD=component" >> "$BASH_ENV"
source "$BASH_ENV"

echo "export POSTGRES_URL=postgres://$POSTGRES_USER:$POSTGRES_PASSWORD@localhost:$POSTGRES_PORT/$POSTGRES_DB?sslmode=disable" >> "$BASH_ENV"
source "$BASH_ENV"

debug() {
    if [[ -n "$DEBUG" ]]; then
        printf "[DEBUG] %s\n" "$*" 1>&2
    fi
}

start_rabbit() {
    debug "starting rabbit"
    # Starts rabbit and applies migrations
    RABBIT_PORT=5672 RABBIT_MGMT_PORT=15672 docker-compose up -d rabbit

    until docker-compose exec rabbit rabbitmqctl await_startup --timeout 60; do
        sleep 1
    done
    # make sure we've started
    docker-compose exec rabbit rabbitmqctl await_startup --timeout 5
}

start_postgres() {
    debug "starting postgres database ${POSTGRES_DB}"
    docker-compose up -d postgres

    until docker-compose exec postgres pg_isready; do
        sleep 1
    done

    docker-compose run migrate
}

docker_compose() {
    if [ -n "${RABBIT}" ]; then
        start_rabbit
    fi

    if [ -n "${POSTGRES}" ]; then
        start_postgres
    fi
}

TEST_ENV="bats-core"
if [ "${0#*$TEST_ENV}" == "$0" ]; then
    # Show inputs
    debug "RABBIT=${RABBIT}"
    debug "POSTGRES=${POSTGRES}"
    debug "POSTGRES_DB=${POSTGRES_DB}"

    docker_compose
fi
