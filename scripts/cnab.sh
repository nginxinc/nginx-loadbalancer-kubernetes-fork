#!/usr/bin/env bash

set -euo pipefail

log() {
    printf "\033[0;36m${*}\033[0m\n" >&2
}

package() {
    log "Not Implemented."
    exit 1
}

validate() {
    CMD="cpa verify -d ${BUNDLE_DIR} --telemetryOptOut"
    ${CMD}

}

set_version() {
    VERSION=$(cat version)
}

update_helm_chart() {
    yq -ie '.global.azure.images.nlk.registry = .nlk.image.registry | .global.azure.images.nlk.image = .nlk.image.repository | .global.azure.images.nlk.tag = env(VERSION)' charts/nlk/values.yaml
}

update_bundle() {
    yq -ie '.version = env(VERSION)' charts/manifest.yaml
}

check_ci() {
    if [[ "$CI" != "true" ]]; then
        log "This script should be the run in the CI only."
        exit 1
    fi
}

set_vars() {
    BUNDLE_DIR="${CI_PROJECT_DIR}/charts/"
}

main() {
    check_ci
    set_vars
    set_version
    update_helm_chart
    update_bundle
    local action="$1"
    case "$action" in
        validate)
	    validate
	    ;;
        package)
	    package
	    ;;
	*)
	    log "Action not supported."
	    exit 1
	    ;;
    esac
}

main "$@"
