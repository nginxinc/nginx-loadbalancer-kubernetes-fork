#!/usr/bin/env bash

set -eo pipefail

ROOT_DIR=$(git rev-parse --show-toplevel)

build() {
    echo "building image: $image"
    DOCKER_BUILDKIT=1 docker build --target "$image" \
        --label VERSION="$version" \
        --label COMMIT="${CI_COMMIT_SHORT_SHA}" \
        --label PROJECT_NAME="${CI_PROJECT_NAME}" \
        --tag "${repo}:${CI_COMMIT_REF_SLUG}" \
        --tag "${repo}:${CI_COMMIT_REF_SLUG}-$version" \
        --tag "${repo}:${CI_COMMIT_SHORT_SHA}" \
        --platform "linux/amd64" \
        -f "${ROOT_DIR}/Dockerfile" .
}

publish() {
    docker push "$repo:${CI_COMMIT_REF_SLUG}"
    docker push "$repo:${CI_COMMIT_REF_SLUG}-$version"
    docker push "$repo:${CI_COMMIT_SHORT_SHA}"
    if [[ "$CI_COMMIT_REF_SLUG" == "${CI_DEFAULT_BRANCH}" ]]; then
        docker tag "$repo:${CI_COMMIT_SHORT_SHA}" "$repo:latest"
        docker tag "$repo:${CI_COMMIT_SHORT_SHA}" "$repo:$version"
        docker push "$repo:latest"
        docker push "$repo:$version"
      fi
}

init_ci_vars() {
    if [ -z "$CI_COMMIT_SHORT_SHA" ]; then
        CI_COMMIT_SHORT_SHA=$(git rev-parse --short=8 HEAD)
    fi
    if [ -z "$CI_PROJECT_NAME" ]; then
        CI_PROJECT_NAME=$(basename "$ROOT_DIR")
    fi
    if [ -z "$CI_COMMIT_REF_SLUG" ]; then
        CI_COMMIT_REF_SLUG=$(
            git rev-parse --abbrev-ref HEAD | tr "[:upper:]" "[:lower:]" \
                | LANG=en_US.utf8 sed -E -e 's/[^a-zA-Z0-9]/-/g' -e 's/^-+|-+$$//g' \
                | cut -c 1-63
        )
    fi
    if [ -z "$CI_DEFAULT_BRANCH" ]; then
        CI_DEFAULT_BRANCH="main"
    fi
}

print_help () {
    echo "Usage:  $(basename "$0") <action>"
}

parse_args() {
    if [[ "$#" -ne 1 ]]; then
        print_help
	exit 0
    fi

    action="$1"

    valid_actions="(build|publish)"
    valid_actions_ptn="^${valid_actions}$"
    if ! [[ "$action" =~ $valid_actions_ptn ]]; then
        echo "Invalid action. Valid actions: $valid_actions"
	print_help
	exit 1
    fi
}

# MAIN
image="nginxaas-loadbalancer-kubernetes"
parse_args "$@"
init_ci_vars

# shellcheck source=/dev/null
source "${ROOT_DIR}/.devops.sh"
if [ "$CI" != "true" ]; then
    devops.backend.docker.set "azure.container-registry-dev"
fi
repo="${DEVOPS_DOCKER_URL}/nginx-azure-lb/${CI_PROJECT_NAME}/$image"
# shellcheck source=/dev/null
# shellcheck disable=SC2153
version=$(cat version)

"$action"
