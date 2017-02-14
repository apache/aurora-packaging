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


if [[ "$USER" != "vagrant" ]]; then
  echo "This script is supposed to run within Vagrant in order to verify an Aurora installation."
  exit 1
fi

set -u -e -x
set -o pipefail

readonly TEST_SLAVE_IP=127.0.0.1

_curl() { curl --silent --fail --retry 4 --retry-delay 10 "$@" ; }


tear_down() {
  aurora job killall --no-batching example/vagrant/test/hello_world >/dev/null 2>&1
}


collect_result() {
  set +x  # Disable command echo, as this makes it more difficult see which command failed.
  if [[ $RETCODE = 0 ]]
  then
    echo "OK (all tests passed)"
  else
    echo "!!! FAIL (something returned non-zero) for $BASH_COMMAND"
  fi
  # Attempt to clean up any state we left behind.
  tear_down
  exit $RETCODE
}


check_url_live() {
  [[ $(curl -sL -w '%{http_code}' $1 -o /dev/null) == 200 ]]
}


test_create_job() {
  echo "
task = SequentialTask(
  processes = [Process(name = 'hello', cmdline = 'echo hello; sleep 120')],
  resources = Resources(cpu = 0.5, ram = 128*MB, disk = 128*MB))
jobs = [Service(
  task = task, cluster = 'example', role = 'vagrant', environment = 'test', name = 'hello_world')]" > hello_world.aurora

  aurora job create example/vagrant/test/hello_world hello_world.aurora
}


test_job_status() {
  local _cluster=$1 _role=$2 _env=$3 _job=$4
  local _jobkey="$_cluster/$_role/$_env/$_job"

  echo "== Checking job status"
  aurora job list $_cluster/$_role/$_env | grep "$_jobkey"
  aurora job status $_jobkey
}


test_scheduler_ui() {
  local _role=$1 _env=$2 _job=$3

  # Check that scheduler UI pages shown
  base_url="$TEST_SLAVE_IP:8081"
  check_url_live "$base_url/leaderhealth"
  check_url_live "$base_url/scheduler"
  check_url_live "$base_url/scheduler/$_role"
  check_url_live "$base_url/scheduler/$_role/$_env/$_job"
}


test_observer_ui() {
  local _cluster=$1 _role=$2 _job=$3

  # Check the observer page
  observer_url="$TEST_SLAVE_IP:1338"
  check_url_live "$observer_url"

  # Poll the observer, waiting for it to receive and show information about the task.
  local _success=0
  for i in $(seq 1 120); do
    task_id=$(aurora-admin query -l '%taskId%' --shards=0 --states=RUNNING $_cluster $_role $_job)
    if check_url_live "$observer_url/task/$task_id"; then
      _success=1
      break
    else
      sleep 1
    fi
  done

  if [[ "$_success" -ne "1" ]]; then
    echo "Observer task detail page is not available."
    exit 1
  fi
}


RETCODE=1
trap collect_result EXIT

test_create_job
test_job_status example vagrant test hello_world
test_scheduler_ui vagrant test hello_world
test_observer_ui example vagrant hello_world

RETCODE=0
