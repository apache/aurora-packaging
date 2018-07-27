#!/bin/bash

apt-get install --reinstall ca-certificates
add-apt-repository ppa:openjdk-r/ppa -y
add-apt-repository -y ppa:jonathonf/python-2.7
apt-get update
apt-get install -y openjdk-8-jre zookeeperd python2.7-minimal

update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java

# NOTE: This appears to be a missing dependency of the mesos deb package and is needed
# for the python mesos native bindings.
sudo apt-get -y install libcurl4-nss-dev libevent-dev libsvn1

package=mesos_1.5.0-2.0.2.ubuntu1404_amd64.deb
wget -c http://repos.mesosphere.com/ubuntu/pool/main/m/mesos/$package
dpkg -i $package

start mesos-master
start mesos-slave
