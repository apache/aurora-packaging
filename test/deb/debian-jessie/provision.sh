#!/bin/bash

echo "deb http://http.debian.net/debian jessie-backports main" | sudo tee -a /etc/apt/sources.list
apt-get update
apt-get install -y openjdk-8-jre-headless -t jessie-backports
apt-get install -y zookeeperd curl

update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java

# NOTE: This appears to be a missing dependency of the mesos deb package and is needed
# for the python mesos native bindings.
aptitude -y install libcurl4-nss-dev libcurl3 libevent-dev libsvn1

package=mesos_1.4.0-2.0.1.debian8_amd64.deb
wget -c http://repos.mesosphere.com/debian/pool/main/m/mesos/$package
dpkg -i $package

systemctl start mesos-master
systemctl start mesos-slave
