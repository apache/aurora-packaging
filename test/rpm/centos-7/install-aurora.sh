#!/bin/bash

DIST_DIR=$1
PACKAGES=$(ls $DIST_DIR/*.rpm)

if [ -z "$PACKAGES" ]
  then
    echo "No packages found to be installed. Aborting."
    exit 1
fi

sudo yum install -y $PACKAGES

sudo -u aurora mkdir -p /var/lib/aurora/scheduler/db
sudo -u aurora mesos-log initialize --path=/var/lib/aurora/scheduler/db || true
sudo systemctl start aurora-scheduler
sudo systemctl start thermos

# Ensure compatibility so that our test-aurora.sh script works on all distributions.
sudo ln -sf /usr/bin/aurora_admin /usr/bin/aurora-admin
