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

tests_dir=/tests
artifact_dir="${tests_dir}/$(basename "${ARTIFACT_FILE}" | cut -f1 -d.)"
headers_dir="${artifact_dir}/FILES/header"
files_dir="${artifact_dir}/FILES/files"
tmp_dir="${artifact_dir}/FILES/tmp"
mkdir -p "${headers_dir}"
mkdir -p "${files_dir}"
mkdir -p "${tmp_dir}"
tree "${tests_dir}"
tar xvf "${ARTIFACT_FILE}" -C "${artifact_dir}"
tar zxvf "${artifact_dir}"/header.tar.gz -C "${artifact_dir}"
cp "${artifact_dir}"/headers/0000/meta-data "${headers_dir}/"
cp "${artifact_dir}"/headers/0000/type-info  "${headers_dir}/"
cp "${artifact_dir}"/header-info "${headers_dir}/"
tar zxvf "${artifact_dir}"/data/0000.tar.gz -C "${artifact_dir}"
cp "${artifact_dir}"/images.tar.gz "${files_dir}/"
cp "${artifact_dir}"/manifests.tar.gz "${files_dir}/"

source conf/mender-app.conf

mkdir -p /usr/share/mender/app-modules/v1
mkdir -p /usr/share/mender/modules/v3
cp src/app /usr/share/mender/modules/v3/
cp src/app-modules/docker-compose /usr/share/mender/app-modules/v1/
chmod 755 /usr/share/mender/modules/v3/app
chmod 755 /usr/share/mender/app-modules/v1/docker-compose
mkdir -p $PERSISTENT_STORE /etc/mender
cp conf/mender-app.conf /etc/mender/
/usr/share/mender/modules/v3/app ArtifactInstall "$(dirname ${files_dir})"
sleep 4
cat $PERSISTENT_STORE/mapp64/manifests/*.yml
cat $PERSISTENT_STORE/mapp64/manifests/*.log
grep -rniHF Pulling $PERSISTENT_STORE/mapp64/manifests/*.log && false
echo
sleep 16
docker ps --format "{{.Image}} {{.Command}}" | sort
diff <(docker ps --format "{{.Image}} {{.Command}}" | sort) <(cat "${EXPECTED_CONTAINERS}")
[[ -d "${DATA}"/output/ ]] || mkdir "${DATA}"/output/
cp -a /tests/* "${DATA}"/output/
