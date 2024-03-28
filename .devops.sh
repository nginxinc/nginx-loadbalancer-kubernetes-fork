#!/usr/bin/env bash

DEVOPS_UTILS_URL=${DEVOPS_UTILS_URL:-"gitlab.com/f5/nginx/tools/devops-utils.git"}
DEVOPS_UTILS_REF=${DEVOPS_UTILS_REF:-"master"}
rootdir=$(git rev-parse --show-toplevel)
devops_utils_dir="${rootdir}/.devops-utils"
git_update_file=${devops_utils_dir}/.last-git-update
ttl_seconds=$((60 * 60))

if [ "${CI}" == "true" ]; then
  url="https://gitlab-ci-token:${CI_JOB_TOKEN}@${DEVOPS_UTILS_URL}"
else
  # - change the first occurrence of "/" to ":" for local git clone
  url="git@${DEVOPS_UTILS_URL/\//:}"
fi

epoch=$(date +%s)

# - get a local copy of devops-utils and update it when it's more than 1h old
if [ ! -d "$devops_utils_dir" ]; then
    if ! git clone -q "${url}" "${devops_utils_dir}" --branch "${DEVOPS_UTILS_REF}" --depth 1; then
      echo "ERROR: failed to clone devops-utils repo!"
      exit 1
    fi
    echo "$epoch" > "$git_update_file"
else
    if [ $((epoch - $(cat "$git_update_file"))) -gt $ttl_seconds ]; then
        cd "$devops_utils_dir" || exit
        git fetch -q origin
        git reset -q --hard origin/"${DEVOPS_UTILS_REF}"
        echo "$epoch" > "$git_update_file"
        cd ..
    fi
fi

# shellcheck disable=SC1090,SC1091
source "${devops_utils_dir}/devops-core-services.sh"
