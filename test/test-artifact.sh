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


run_test() {
  TEST_DIR=$1
  DIST_DIR=$2

  pushd $TEST_DIR
    vagrant up --provision

    # Install Aurora using the distribution specific install script
    vagrant ssh -c "/vagrant/install-aurora.sh $DIST_DIR"

    # Verify Aurora using the generic test script
    vagrant ssh -c "/repo/test/test-aurora.sh" -- -L8081:localhost:8081 -L1338:localhost:1338

    vagrant halt --force
  popd
}

case $# in
  2)
    run_test "$@"
    ;;

  *)
    echo 'Usage to test a specific artifact:'
    echo "  $0 TEST_DIR DIST_DIR"
    echo
    echo 'Where TEST_DIR is any distribution subfolder with a Vagrantfile'
    echo ' and where DIST_DIR is location within the Vagrant box where packages should be installed from.'
    echo
    echo 'Example:'
    echo ' ./test/test-artifact.sh test/deb/ubuntu-trusty/ /repo/artifacts/aurora-ubuntu-trusty/dist'
    exit 1
    ;;
esac
