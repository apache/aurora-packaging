#!/bin/bash

DIST_DIR=$1
PACKAGES=$(ls $DIST_DIR/*.deb)

if [ -z "$PACKAGES" ]
  then
    echo "No packages found to be installed. Aborting."
    exit 1
fi

sudo dpkg -i $PACKAGES

sudo stop aurora-scheduler
sudo -u aurora mkdir -p /var/lib/aurora/scheduler/db
sudo -u aurora mesos-log initialize --path=/var/lib/aurora/scheduler/db || true
sudo start aurora-scheduler
