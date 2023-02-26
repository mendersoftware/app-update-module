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

function g() {
    echo   -e "\E[0;32m$@\E[0m"
}

function y() {
    echo   -e "\E[33;1m$@\E[0m"
}

function b() {
    echo   -e "\E[34;1m$@\E[0m"
}

export -f g
export -f y
export -f b
