#!/usr/bin/env bash

set -eo pipefail

rootdir=$(git rev-parse --show-toplevel)
docker_login_file=${rootdir}/.devops-utils/.last-docker-login

# - perform a new docker login if last login was more than 1h ago
ttl_seconds=$((60 * 60))

epoch=$(date +%s)

if [ -e "$docker_login_file" ] && [ $((epoch - $(cat "$docker_login_file"))) -lt $ttl_seconds ]; then
    exit 0
fi

# shellcheck disable=1090
source "${rootdir}/.devops.sh"
devops.docker.login > /dev/null
if [ "$CI" != "true" ]; then
    devops.backend.docker.set "azure.container-registry-dev"
    devops.docker.login > /dev/null
fi
echo "$epoch" > "$docker_login_file"
