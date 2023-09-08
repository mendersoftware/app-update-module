#!/usr/bin/env bash
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

function test_phase_setup() {
    echo "entering setup phase"
    curl -fLsS https://get.mender.io -o get-mender.sh
    bash get-mender.sh || return 1
    make install || return 1
    ls -al /usr/share/mender/modules/v3/app || return 1
    ls -al /usr/share/mender/app-modules/v1/k8s || return 1
    wget 'https://downloads.mender.io/mender-artifact/master/linux/mender-artifact' -O /usr/bin/mender-artifact
    chmod 755 /usr/bin/mender-artifact
    mender-artifact --version || return 1
    k3d cluster create acceptance-tests
    return 0
}

function test_phase_run() {
    local -r temp_dir=$(mktemp -d)
    local -r artifact_file="${temp_dir}/a0.mender"
    local -r artifact_name=$(basename "$temp_dir")
    local image1
    local image2
    local -r timeout_s=32

    echo "entering run phase"
    image1=docker.io/library/postgres:15.4
    "${GENERATOR:-./gen/app-gen}" \
        --artifact-name "${artifact_name}" \
        --device-type "$(cat /var/lib/mender/device_type | sed -e 's/^.*=//')" \
        --output-path "${artifact_file}" \
        --image "${image1}" \
        --platform linux/amd64 \
        --orchestrator k8s \
        --k8s-namespace acceptance-tests \
        --manifests-dir acceptance-tests/data/k8s-manifests-1 \
        --application-name myapp0 || return 1

    mender install "$artifact_file" || return 2
    sleep "${timeout_s}"
    kubectl get pods --namespace acceptance-tests
    return 0
}

function test_failed_hook_phase_run() {
    echo "test run failed."
    exit 1
}

function test_failed_hook_phase_setup() {
    echo "tests setup failed."
    exit 1
}
