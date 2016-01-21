#!/bin/bash

echo "deb http://http.debian.net/debian jessie-backports main" | sudo tee -a /etc/apt/sources.list
apt-get update
apt-get install -y openjdk-8-jre libsvn1 zookeeperd

update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java

package=mesos_0.26.0-0.2.145.debian81_amd64.deb
wget -c http://downloads.mesosphere.io/master/debian/8/$package
dpkg -i $package
