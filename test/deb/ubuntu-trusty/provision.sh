#!/bin/bash

add-apt-repository ppa:openjdk-r/ppa -y
apt-get update
apt-get install -y openjdk-8-jre libsvn1 zookeeperd

update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java

package=mesos_0.24.1-0.2.35.ubuntu1404_amd64.deb
wget -c https://downloads.mesosphere.io/master/ubuntu/14.04/$package
dpkg -i $package
start mesos-master
