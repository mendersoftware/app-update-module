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

root_dir=$(dirname $0)
root_dir=$(cd "$root_dir" && pwd)
module=$(cd "$root_dir" && pwd | sed -e 's|tests/app|src/app|')
module=${MODULE_EXEC:-${module}}
[[ "${root_dir}" == "" ]] && echo "ERROR: cant determine root_dir"
scenarios_dir="${root_dir}/scenarios"
artifact_file=${TEST_ARTIFACT_FILE:-"${root_dir}/data/m64.mender"}
mkdir /tests
cp "$artifact_file" /tests/
artifact_file=/tests/$(basename "$artifact_file")

while read -r; do
    echo "running $REPLY"
    EXPECTED_CONTAINERS="${root_dir}/data/docker"/expected.containers.txt ARTIFACT_FILE="${artifact_file}" DATA="${root_dir}/data/docker" MODULE="${module}" "$REPLY" && echo -e "$REPLY \E[0;32mPASSED\E[0m"
done < <(find "$scenarios_dir" -mindepth 1 -maxdepth 1 -name "*run.sh")

artifact_file=${TEST_ARTIFACT_FILE:-"${root_dir}/data/d64.mender"}
cp "$artifact_file" /tests/
artifact_file=/tests/$(basename "$artifact_file")

while read -r; do
    echo "running $REPLY"
    EXPECTED_CONTAINERS="${root_dir}/data/docker"/expected.containers-delta.txt ARTIFACT_FILE="${artifact_file}" DATA="${root_dir}/data/docker" MODULE="${module}" "$REPLY" && echo -e "$REPLY \E[0;32mPASSED\E[0m"
done < <(find "$scenarios_dir" -mindepth 1 -maxdepth 1 -name "*run.sh")
