#!/bin/bash

add-apt-repository ppa:openjdk-r/ppa -y
apt-get update
apt-get install -y openjdk-8-jre libcurl4-nss-dev libevent-dev libsvn1 zookeeperd

update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java

package=mesos_1.0.0-2.0.89.ubuntu1404_amd64.deb
wget -c http://repos.mesosphere.com/ubuntu/pool/main/m/mesos/$package
dpkg -i $package

# NOTE: This appears to be a missing dependency of the mesos deb package and is needed
# for the python mesos native bindings.
sudo apt-get -y install libcurl4-nss-dev

start mesos-master
start mesos-slave
