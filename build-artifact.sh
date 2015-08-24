#!/bin/bash
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -eu

print_available_builders() {
  find builder -name Dockerfile | sed "s/\/Dockerfile$//"
}

if [[ $# -ne 2 ]]; then
  echo "usage: $0 BUILDER RELEASE_TAR"
  echo 'Where BUILDER is a builder directory in:'
  print_available_builders
  exit 1
else
  BUILDER_DIR=$1
  RELEASE_TAR=$2
fi

IMAGE_NAME="aurora-$(basename $BUILDER_DIR)"
docker build -t "$IMAGE_NAME" "$BUILDER_DIR"

ARTIFACT_DIR="$(pwd)/dist/$BUILDER_DIR"
mkdir -p $ARTIFACT_DIR
docker run \
  --rm \
  -v "$(pwd)/specs:/specs:ro" \
  -v "$(realpath $RELEASE_TAR):/src.tar.gz:ro" \
  -v "$ARTIFACT_DIR:/dist" \
  -t "$IMAGE_NAME" /build.sh

echo 'Produced artifacts:'
ls $ARTIFACT_DIR
