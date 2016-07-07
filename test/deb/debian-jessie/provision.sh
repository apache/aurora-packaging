#!/bin/bash

echo "deb http://http.debian.net/debian jessie-backports main" | sudo tee -a /etc/apt/sources.list
apt-get update
apt-get install -y openjdk-8-jre libsvn1 zookeeperd

update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java

package=mesos_0.28.2-2.0.27.debian81_amd64.deb
wget -c http://repos.mesosphere.com/debian/pool/main/m/mesos/$package
dpkg -i $package

# NOTE: This appears to be a missing dependency of the mesos deb package and is needed
# for the python mesos native bindings.
sudo apt-get -y install libcurl4-nss-dev

systemctl start mesos-master
systemctl start mesos-slave
