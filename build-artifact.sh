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

realpath() {
  echo "$(cd "$(dirname "$1")"; pwd)/$(basename "$1")"
}

run_build() {
  BUILDER_DIR=$1
  RELEASE_TAR=$2
  AURORA_VERSION=$3

  IMAGE_NAME="aurora-$(basename $BUILDER_DIR)"
  echo "Using docker image $IMAGE_NAME"
  docker build -t "$IMAGE_NAME" "$BUILDER_DIR"

  docker run \
    -e AURORA_VERSION=$AURORA_VERSION \
    -v "$(pwd)/specs:/specs:ro" \
    -v "$(realpath $RELEASE_TAR):/src.tar.gz:ro" \
    -t "$IMAGE_NAME" /build.sh
  container=$(docker ps -l -q)
  artifact_dir="artifacts/$IMAGE_NAME"
  mkdir -p "$artifact_dir"
  docker cp $container:/dist "$artifact_dir"
  docker rm "$container"

  echo "Produced artifacts in $artifact_dir:"
  ls -R "$artifact_dir"
}

case $# in
  2)
    for builder in $(print_available_builders); do
      run_build $builder $1 $2
      echo $builder
    done
    ;;

  3)
    run_build "$@"
    ;;

  *)
    echo 'usage:'
    echo 'to build all artifacts:'
    echo "  $0 RELEASE_TAR AURORA_VERSION"
    echo
    echo 'or to build a specific artifact:'
    echo "  $0 BUILDER RELEASE_TAR AURORA_VERSION"
    echo
    echo 'Where BUILDER is a builder directory in:'
    print_available_builders
    exit 1
    ;;
esac
