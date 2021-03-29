#!/usr/bin/env bash
set -eu

# Only files that have absolutely no bearing on our code should be listed here
PAT='*\.(md|tf|svg|png)$|VERSION'

set +o pipefail
CHANGES=$(git diff --name-only HEAD~1 | grep -cvE "$PAT")
set -o pipefail

if [ "$CHANGES" = "0" ]; then
    circleci step halt
fi
