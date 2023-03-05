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

export BT_ROOT_DIR=$(dirname "${BASH_SOURCE[0]}")

. "${BT_ROOT_DIR}/bt.sh"

BT_DEFAULT_PHASES=(
    "setup"
    "build"
    "run"
    "collect"
)

if [[ "${#TEST_PHASES_NAMES[@]}" == "" || ${#TEST_PHASES_NAMES[@]} -lt 1 ]]; then
    TEST_PHASES_NAMES=()
    for ((i = 0; i < ${#BT_DEFAULT_PHASES[@]}; i++)); do
        TEST_PHASES_NAMES+=(${BT_DEFAULT_PHASES[${i}]})
    done
fi

while read -r scenario; do
    (   
        . "$scenario"
        for ((i = 0; i < ${#TEST_PHASES_NAMES[@]}; i++)); do
            p="${TEST_PHASES_NAMES[${i}]}"
            bt_call_functions_by_phase "$p"
        done
    )
done < <(find "${1}" -mindepth 1 -maxdepth 1 -and -name "*.sh" -and -type f)
