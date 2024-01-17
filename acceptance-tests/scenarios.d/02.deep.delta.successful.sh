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

function test_phase_setup_deep_delta() {
    echo "entering regular delta setup phase"
    curl -fLsS https://get.mender.io -o get-mender.sh
    bash get-mender.sh || return 1
    make install || return 1
    ls -al /usr/share/mender/modules/v3/app || return 1
    ls -al /usr/share/mender/app-modules/v1/docker-compose || return 1
    wget 'https://downloads.mender.io/mender-artifact/master/linux/mender-artifact' -O /usr/bin/mender-artifact
    chmod 755 /usr/bin/mender-artifact
    mender-artifact --version || return 1
    docker stop $(docker ps -qa)
    docker container rm $(docker container ls -aq)
    docker image rmi $(docker image ls -q)
    docker system prune -a -f
    docker volume rm $(docker volume ls -q)
    return 0
}

function test_phase_run_deep_delta() {
    local -r temp_dir=$(mktemp -d)
    local -r artifact_file="${temp_dir}/a0.mender"
    local -r artifact_name=$(basename "$temp_dir")
    local image1d
    local image2d
    local image1
    local image2
    local -r timeout_s=32
    local log="mktemp -u --tmpdir=${temp_dir}"

    echo "entering regular delta run phase"
    image1d=docker.io/library/alpine:3.13
    image2d=docker.io/library/memcached:1.6.17-alpine
    docker pull "$image1d"
    docker pull "$image2d"
    image1=docker.io/library/alpine:3.14
    image2=docker.io/library/memcached:1.6.18-alpine
    "${GENERATOR:-./gen/app-gen}" \
        --artifact-name "${artifact_name}" \
        --device-type "$(cat /var/lib/mender/device_type | sed -e 's/^.*=//')" \
        --output-path "${artifact_file}" \
        --image "${image1d},${image1}" \
        --image "${image2d},${image2}" \
        --platform linux/amd64 \
        --orchestrator docker-compose \
        --manifests-dir acceptance-tests/data/manifests-1 \
        --application-name myapp2 \
        --deep-delta || return 1
    mender-update install "$artifact_file" | tee -a "$log"
    [[ ${PIPESTATUS[0]} -eq 0 ]] || {
        echo "install artifact failed"
        return 2
    }
    sleep "${timeout_s}"
    docker ps
    diff <(docker ps --format '{{.Image}}' | sort) <(echo -ne "$(basename ${image1})\n$(basename ${image2})\n" | sort) || return 3
    grep  -F Pulling /data/mender-app/myapp2/manifests/*.log && {
        echo "up log contains evidence of image pulling"
        return 4
    }
    grep  -F Pulling "$log" && {
        echo "install log contains evidence of image pulling"
        return 5
    }
    return 0
}

function test_failed_hook_phase_run_deep_delta() {
    echo "test regular delta run failed."
    exit 1
}

function test_failed_hook_phase_setup_regular_delta() {
    echo "tests regular delta setup failed."
    exit 1
}
