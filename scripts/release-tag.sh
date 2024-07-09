#!/usr/bin/env bash

### This script should only run during master pipelines ###
### This script will create tags for the master commit using the current version ###

set -eo pipefail

if [ "$CI_COMMIT_REF_NAME" = "main" ]; then
    # shellcheck source=/dev/null
    version_tag=v$(source version;echo "$VERSION")

    curl -s \
      --request POST \
      --header "PRIVATE-TOKEN: ${GITLAB_API_TOKEN_RW}" \
      "https://gitlab.com/api/v4/projects/${CI_PROJECT_ID}/repository/tags" \
      --form "tag_name=$version_tag" \
      --form "ref=$CI_COMMIT_SHA"
fi
