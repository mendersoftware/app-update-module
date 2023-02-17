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
generator=$(cd "$root_dir" && pwd | sed -e 's|tests/gen|gen/app-gen|')
generator=${GENERATOR_EXEC:-${generator}}
[[ "${root_dir}" == "" ]] && echo "ERROR: cant determine root_dir"
scenarios_dir="${root_dir}/scenarios"
wget 'https://downloads.mender.io/mender-artifact/master/linux/mender-artifact' -O /usr/bin/mender-artifact
chmod 755 /usr/bin/mender-artifact

while read -r; do
    DATA="${root_dir}/data/docker" GENERATOR="${generator}" "$REPLY" && echo -e "$REPLY \E[0;32mPASSED\E[0m"
done < <(find "$scenarios_dir" -mindepth 1 -maxdepth 1 -name "*run.sh")
