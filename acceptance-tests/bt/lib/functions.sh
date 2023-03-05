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

Re="\E[0m"
G="\E[0;32m"
R="\E[31m"

function bt_get_functions_by_prefix() {
    declare -F | sed -e 's/^declare -f //' | sed -n "/^${1}/p"
}

function bt_call_failure_hook() {
    local -r phase="$1"
    shift
    while read -r f; do
        . <(echo "$f" \""$@"\")
    done < <(bt_get_functions_by_prefix "test_failed_hook_phase_${phase}")
}

function log() {
    local -r message="$1"
    local -r timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local -r script_name="$(basename -- "$0")"
    local line_index
    local frame=1

    [[ ${FUNCNAME[$frame]} == log_* ]] && let frame++
    let line_index=frame-1
    trace="${FUNCNAME[$frame]}:${BASH_LINENO[${line_index}]}"

    echo >&2 -e "${timestamp} [$$:$script_name:${trace}] ${message}"
}
