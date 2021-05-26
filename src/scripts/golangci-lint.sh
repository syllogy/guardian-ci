#!/usr/bin/env bash
set -euo pipefail

function cleanup() {
  rm .golangci.yml
}

if [[ ! -f .golangci.yml ]]; then
  cat <<EOF >.golangci.yml
linters:
  enable:
    - gci
linters-settings:
  gci:
    local-prefixes: github.com/BishopFox
EOF

  trap cleanup EXIT
fi

golangci-lint run
