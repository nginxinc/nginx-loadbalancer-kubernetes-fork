#!/usr/bin/env bash

set -eo pipefail

docker-image() {
    SRC_PATH="nginx-azure-lb/nginxaas-operator/nginxaas-operator"
    SRC_TAG=$(echo "${CI_COMMIT_TAG}" | cut -f 2 -d "-")
    SRC_IMG="${SRC_REGISTRY}/${SRC_PATH}:main-${SRC_TAG}"
    DST_PATH="nginx/nginxaas-operator"
    DST_TAG="${CI_COMMIT_TAG}"
    DST_IMG="${DST_REGISTRY}/${DST_PATH}:${DST_TAG}"

    docker pull "${SRC_IMG}"
    docker tag "${SRC_IMG}" "${DST_IMG}"
    docker push "${DST_IMG}"
}

helm-chart() {
    SRC_PATH="nginx-azure-lb/nginxaas-operator/charts/main/nginx-loadbalancer-kubernetes"
    SRC_TAG="0.1.0"
    SRC_CHART="oci://${SRC_REGISTRY}/${SRC_PATH}"
    DST_PATH="nginxcharts"
    DST_TAG="0.1.0"
    DST_CHART="oci://${DST_REGISTRY}/${DST_PATH}"

    helm pull "${SRC_CHART}" --version "${SRC_TAG}"
    helm push nginx-loadbalancer-kubernetes-${DST_TAG}.tgz "${DST_CHART}"
}


help_text() {
    echo "Usage: $(basename $0) <artifact-type>"
}

set_docker_common() {
    DOCKERHUB_USERNAME=$(devops.secret.get "kic-dockerhub-creds" | jq -r ".username")
    if [[ -z "${DOCKERHUB_USERNAME}" ]]; then
        echo "DOCKERHUB_USERNAME needs to be set."
        exit 1
    fi

    DOCKERHUB_PASSWORD=$(devops.secret.get "kic-dockerhub-creds" | jq -r ".password")
    if [[ -z "${DOCKERHUB_PASSWORD}" ]]; then
        echo "DOCKERHUB_PASSWORD needs to be set."
        exit 1
    fi
    SRC_REGISTRY="${DEVOPS_DOCKER_URL}"
    DST_REGISTRY="docker.io"

    # Login to NGINX DevOps Registry.
    devops.docker.login
    # Login to Dockerhub.
    docker login --username "${DOCKERHUB_USERNAME}" --password "${DOCKERHUB_PASSWORD}" "${DST_REGISTRY}"
}

parse_args() {
    if [[ "$#" -ne 1 ]]; then
        help_text
        exit 0
    fi

    artifact="${1}"
    valid_artifact="(docker-image|helm-chart)"
    valid_artifact_pttn="^${valid_artifact}$"
    if ! [[ "${artifact}" =~ $valid_artifact_pttn ]]; then
        echo "Invalid artifact type. Valid artifact types: $valid_artifact"
        help_text
        exit 1
    fi
}

main() {
    if [[ "${CI}" != "true" ]]; then
        echo "This script is meant to be run in the CI."
        exit 1
    fi
    pttn="^release-[0-9]+\.[0-9]+\.[0-9]+"
    if ! [[ "${CI_COMMIT_TAG}" =~ $pttn ]]; then
        echo "CI_COMMIT_TAG needs to be set to valid semver format."
        exit 1
    fi
    parse_args "$@"
    ROOT_DIR=$(git rev-parse --show-toplevel)
    source ${ROOT_DIR}/.devops.sh
    set_docker_common
    "$artifact"
}

main "$@"
