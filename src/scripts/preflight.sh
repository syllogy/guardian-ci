#!/usr/bin/env bash
set -euo pipefail

pr_number=$(echo "$CIRCLE_PULL_REQUEST" | cut -d / -f 7)
draft_pr_status_url="https://api.github.com/repos/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/pulls/$pr_number"
pr_status_result=$(curl --silent -H "Accept: application/vnd.github.shadow-cat-preview+json" -H "Authorization: token $GITHUB_TOKEN" "$draft_pr_status_url")
not_draft_pr=$(echo "$pr_status_result" | jq '.draft == false')


if ${not_draft_pr}; then
  echo "Not a draft PR, running pipeline..."
else
  echo "PR status: $pr_status_result"
  echo "This is a draft pr. Skipping..."
  exit 1
fi