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

. "${BT_ROOT_DIR}/lib/functions.sh"

function log_passed() {
    local -r f="${1/test_phase_/}"
    log "$f ${G}passed${Re}"
}

function log_failed() {
    local -r f="${1/test_phase_/}"
    log "$f ${R}failed${Re}"
}

function bt_call_functions_by_phase() {
    local -r phase="$1"
    local f

    while read -r f; do
        . <(echo "$f")
        rc=$?
        if [[ $rc -eq 0 ]]; then
            log_passed "$f"
        else
            log_failed "$f"
            bt_call_failure_hook "$phase" "$f"
        fi
    done < <(bt_get_functions_by_prefix "test_phase_${phase}")
}
