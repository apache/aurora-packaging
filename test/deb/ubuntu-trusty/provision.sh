#!/bin/bash

add-apt-repository ppa:openjdk-r/ppa -y
apt-get update
apt-get install -y openjdk-8-jre libsvn1 zookeeperd

update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java

wget -c https://downloads.mesosphere.io/master/ubuntu/14.04/mesos_0.22.0-1.0.ubuntu1404_amd64.deb
dpkg -i mesos_0.22.0-1.0.ubuntu1404_amd64.deb
start mesos-master
