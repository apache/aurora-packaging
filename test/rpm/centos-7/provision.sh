#!/bin/bash

rpm -Uvh https://archive.cloudera.com/cdh4/one-click-install/redhat/6/x86_64/cloudera-cdh-4-0.x86_64.rpm
yum -y install java-1.8.0-headless zookeeper-server
service zookeeper-server init
systemctl start zookeeper-server

rpm -Uvh https://repos.mesosphere.io/el/7/noarch/RPMS/mesosphere-el-repo-7-1.noarch.rpm
yum -y install mesos-0.26.0

systemctl start mesos-master
systemctl start mesos-slave
