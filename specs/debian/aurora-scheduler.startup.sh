#!/bin/bash
#
# Starts up an Aurora scheduler process.
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

source /etc/default/aurora-scheduler

# Environment variables control the behavior of the Mesos scheduler driver (libmesos).
export GLOG_v LIBPROCESS_PORT LIBPROCESS_IP
export JAVA_OPTS="${JAVA_OPTS[*]}"

# Preferences Java 1.8 over any other Java version.
export PATH=/usr/lib/jvm/java-1.8.0/bin:${PATH}

exec /usr/sbin/aurora-scheduler \
  -cluster_name="$CLUSTER_NAME" \
  -http_port="$HTTP_PORT" \
  -native_log_quorum_size="$QUORUM_SIZE" \
  -zk_endpoints="$ZK_ENDPOINTS" \
  -mesos_master_address="$MESOS_MASTER" \
  -serverset_path="$ZK_SERVERSET_PATH" \
  -native_log_zk_group_path="$ZK_LOGDB_PATH" \
  -native_log_file_path="$LOGDB_FILE_PATH" \
  -backup_dir="$BACKUP_DIR" \
  -thermos_executor_path="$THERMOS_EXECUTOR_PATH" \
  -thermos_executor_resources="$THERMOS_EXECUTOR_RESOURCES" \
  -thermos_executor_flags="$THERMOS_EXECUTOR_FLAGS" \
  -allowed_container_types="$ALLOWED_CONTAINER_TYPES" \
  $EXTRA_SCHEDULER_ARGS
