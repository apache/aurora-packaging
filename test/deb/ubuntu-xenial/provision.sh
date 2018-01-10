#!/bin/bash

apt-get update

apt-get install -y openjdk-8-jre zookeeperd

update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java

# Mesos dependencies
apt-get -y install libcurl3 libevent-dev libsvn1 libcurl4-nss-dev

package=mesos_1.4.0-2.0.1.ubuntu1604_amd64.deb
wget -c http://repos.mesosphere.com/ubuntu/pool/main/m/mesos/$package
dpkg -i $package

systemctl start mesos-master
systemctl start mesos-slave
