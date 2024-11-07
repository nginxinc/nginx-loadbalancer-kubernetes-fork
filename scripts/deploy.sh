#!/usr/bin/env bash

set -eo pipefail


if [ -z "$KUBECONFIG" ]; then
    echo "KUBECONFIG is not set."
    exit 1
fi
if [ ! -e "$KUBECONFIG" ]; then
    echo "KUBECONFIG does not exist."
    exit 1
fi

root_dir=$(git rev-parse --show-toplevel)
# shellcheck source=/dev/null
source "${root_dir}/.devops.sh"
devops.backend.docker.set "azure.container-registry-dev"
devops.backend.docker.authenticate

namespace="nlk"
helm_release_name="release-1"
registry="${DEVOPS_DOCKER_URL}"
repository="nginx-azure-lb/nginxaas-loadbalancer-kubernetes/nginxaas-loadbalancer-kubernetes"
image_tag=$(git rev-parse --short=8 HEAD)

kubectl create namespace "${namespace}" --dry-run=client -o yaml | kubectl apply -f -
kubectl -n "${namespace}" create secret docker-registry regcred \
    --docker-username="${DEVOPS_DOCKER_USER}" \
    --docker-password="${DEVOPS_DOCKER_PASS}" \
    --docker-server="${DEVOPS_DOCKER_URL}" \
    --dry-run=client -o yaml | kubectl apply -f -

helm -n "$namespace" upgrade "$helm_release_name" ${root_dir}/charts/nlk/ \
    --set nlk.image.registry="${registry}",nlk.image.repository="${repository}",nlk.image.tag="${image_tag}",nlk.imagePullSecrets[0].name=regcred \
    --install \
    --reuse-values \
    --wait \
    --timeout 2m
