#!/bin/bash
# Copyright 2023 Northern.tech AS
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

set -x
set -e

temp_dir=$(mktemp -d)

function cleanup() {
    set +e
    rm -Rf "${temp_dir}"
}

trap cleanup SIGTERM SIGHUP SIGINT SIGQUIT SIGINT EXIT

artifact_file="${temp_dir}/a0.mender"
artifact_name=$(basename "$temp_dir")
"${GENERATOR:-./gen/app-gen}" \
    --image docker.io/library/debian:10,docker.io/library/debian:latest \
    --image docker.io/library/postgres:15.0,docker.io/library/postgres:15.1 \
    --artifact-name "${artifact_name}" \
    --device-type FP.VT-04 \
    --output-path "${artifact_file}" \
    --manifests-dir "${DATA}"/manifests \
    --orchestrator docker-compose \
    --application-name myapp4 \
    --platform linux/arm/v7 \
    --deep-delta

artifact_file_non_deep="${temp_dir}/a0-non-deep.mender"
artifact_name_non_deep=$(basename "$temp_dir")-non-deep
"${GENERATOR:-./gen/app-gen}" \
    --image docker.io/library/debian:10,docker.io/library/debian:latest \
    --image docker.io/library/postgres:15.0,docker.io/library/postgres:15.1 \
    --artifact-name "${artifact_name_non_deep}" \
    --device-type FP.VT-04 \
    --output-path "${artifact_file_non_deep}" \
    --manifests-dir "${DATA}"/manifests \
    --orchestrator docker-compose \
    --application-name myapp4 \
    --platform linux/arm/v7

ls -sh "${artifact_file}" "${artifact_file_non_deep}"
deep_size=$(stat -c %s "${artifact_file}")
regular_size=$(stat -c %s "${artifact_file_non_deep}")
echo "delta artifact size: ${regular_size}b"
echo "deep delta artifact size: ${deep_size}b"
[[ ${deep_size} -lt ${regular_size} ]]
p=$(awk -v b="${deep_size}" -v a="${regular_size}" 'BEGIN{printf("%0.2lf%%",(a-b)*100.0/((a+b)*0.5));}')
echo "relative percentage gain in deep size: $((regular_size - deep_size)) (${p})"
# lets clean everything.
docker stop $(docker ps -qa) || true
docker container rm $(docker container ls -aq) || true
docker image rmi $(docker image ls -q) || true
docker system prune -a -f || true
docker volume rm $(docker volume ls -q) || true

# now we will unpack the artifact
artifact_dir="${temp_dir}/${artifact_name}"
mkdir -p "${artifact_dir}"
tar xvf "${artifact_file}" -C "${artifact_dir}"
tar xvzf "${artifact_dir}"/data/0000.tar.gz -C "${artifact_dir}"
tar xvzf "${artifact_dir}"/images.tar.gz -C "${artifact_dir}"

# lets find the postgres:15.1 image
expected_image_tag=postgres:15.1
image_file=""
while read -r; do
    url=$(cat "$REPLY")
    if [[ "$url" == "docker.io/library/${expected_image_tag}" ]]; then
        image="$(dirname "${REPLY}")/image.img"
        break
    fi
done < <(find "${artifact_dir}"/images -name 'url-new.txt')
[[ "$image" == "" ]] && {
    echo "assertion failed: cant find image."
    exit 1
}

# we will now call LOAD operation from the docker-compose orchestrator submodule
# we assume that the current image is present, so we will pull it
docker pull docker.io/library/postgres:15.0 --platform linux/arm/v7
# and call the submodule, the way the main update module calls
mkdir -p "${temp_dir}/temp"
MODULE_TMPDIR="${temp_dir}/temp" OPTIONS="deep_delta" ${DOCKER_COMPOSE_SUBMODULE:-./src/app-modules/docker-compose} \
    LOAD \
    myapp \
    docker.io/library/${expected_image_tag} \
    "${image}" \
    docker.io/library/postgres:15.0

diff \
    <(docker image ls --format '{{.Repository}}:{{.Tag}}' | grep ^"${expected_image_tag}"$) \
    <(echo "${expected_image_tag}")
