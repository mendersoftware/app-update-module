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

function test_phase_setup_k8s_rollback_on_broken_yaml() {
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
    kubectl get nodes
    mv -f /usr/bin/ctr /usr/bin/ctr-prev
    ln -sf /bin/true /bin/ctr
    ln -sf /bin/true /usr/bin/ctr
    wget -qO /usr/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
    chmod 755 /usr/bin/yq
    return 0
}

function test_phase_run_k8s_rollback_on_broken_yaml() {
    local -r temp_dir=$(mktemp -d)
    local -r artifact_file="acceptance-tests/data/k8s-a0.mender"
    local -r artifact_file_broken_yaml="acceptance-tests/data/k8s-a1-broken-yaml.mender"
    local -r timeout_s=32
    local password
    local -r expected_password="aCPu8t0u"

    mv -f /var/lib/mender/device_type /var/lib/mender/device_type-prev
    echo "device_type=dev0" > /var/lib/mender/device_type
    kubectl get pods --namespace acceptance-tests
    mender-update install "$artifact_file" || return 2
    sleep "${timeout_s}"
    kubectl get pods --namespace acceptance-tests | grep -q ^postgres-deployment-
    [[ $? -eq 0 ]] || return 4
    kubectl get secrets --namespace acceptance-tests | grep -q ^postgres-secret
    [[ $? -eq 0 ]] || return 5
    password=$(kubectl get secrets --namespace acceptance-tests -o yaml postgres-secret | /usr/bin/yq -r .data.password - | base64 --decode)
    [[ "$password" == "$expected_password" ]] || return 6
    kubectl get deployments --namespace acceptance-tests | grep -q ^postgres-deployment
    [[ "$password" == "$expected_password" ]] || return 7
    kubectl get services --namespace acceptance-tests | grep -q ^postgres-service
    kubectl get services,secrets,deployments --namespace acceptance-tests

    mender-update install "$artifact_file_broken_yaml" && return 20
    sleep "${timeout_s}"
    kubectl get pods --namespace acceptance-tests | grep -q ^postgres-deployment-
    [[ $? -eq 0 ]] || return 4
    kubectl get secrets --namespace acceptance-tests | grep -q ^postgres-secret
    [[ $? -eq 0 ]] || return 5
    password=$(kubectl get secrets --namespace acceptance-tests -o yaml postgres-secret | /usr/bin/yq -r .data.password - | base64 --decode)
    [[ "$password" == "$expected_password" ]] || return 6
    kubectl get deployments --namespace acceptance-tests | grep -q ^postgres-deployment
    [[ "$password" == "$expected_password" ]] || return 7
    kubectl get services --namespace acceptance-tests | grep -q ^postgres-service
    kubectl get services,secrets,deployments --namespace acceptance-tests

    return 0
}

function test_failed_hook_phase_run_k8s_rollback_on_broken_yaml() {
    echo "test run failed."
    mv -f /usr/bin/ctr-prev /usr/bin/ctr
    mv -f /var/lib/mender/device_type-prev /var/lib/mender/device_type
    exit 1
}

function test_failed_hook_phase_setup_k8s_rollback_on_broken_yaml() {
    echo "tests setup failed."
    mv -f /usr/bin/ctr-prev /usr/bin/ctr
    mv -f /var/lib/mender/device_type-prev /var/lib/mender/device_type
    exit 1
}
