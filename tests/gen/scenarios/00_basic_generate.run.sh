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
# for the test purposes we will get the shasums of both images,
# and save them in the expected metadata file
image1=docker.io/library/alpine:3.14
image2=docker.io/library/memcached:1.6.18-alpine
docker pull "${image1}"
docker pull "${image2}"
sha1=$(docker inspect "${image1}" --format '{{.Id}}' | cut -f2 -d:)
sha2=$(docker inspect "${image2}" --format '{{.Id}}' | cut -f2 -d:)
expected_meta_file="${DATA}/expected.metadata.json"
cat "$expected_meta_file".in | sed -e "s/%sha1/${sha1}/g" -e "s/%sha2/${sha2}/g" > "${expected_meta_file}"
"${GENERATOR:-./gen/app-gen}" --artifact-name "${artifact_name}" --device-type FP.VT-04 --output-path "${artifact_file}" --image "${image1}" --image "${image2}" --platform linux/amd64 --orchestrator docker-compose --manifests-dir "${DATA}"/manifests --application-name myapp0
mkdir "${DATA}/output"
cp "${artifact_file}" "${DATA}/output/"

cd "$temp_dir"
mkdir "${artifact_name}"
cd "${artifact_name}"
tar xvf "$artifact_file"
tar xvf header.tar
cat headers/0000/meta-data | jq .
cat "$expected_meta_file" | jq .
# we compare the metadata from artifact with the expected one.
# there is no way telling which image sha will come first, so we sort,
# and trim the ',' at the end, in case the ordering changed
diff <(cat headers/0000/meta-data | jq . | sort | sed -e 's/,$//') <(cat "$expected_meta_file" | jq . | sort | sed -e 's/,$//')
