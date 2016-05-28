# Installing Aurora

## Install packages

Two methods are described, one for installing locally built packages, the other
for installing released packages or release candidate packages.

### Locally built

    # Install vagrant scp
    vagrant plugin install vagrant-scp

    # Scp over the newly built packages
    for rpm in ../../../artifacts/aurora-centos-7/dist/rpmbuild/RPMS/x86_64/*.rpm; do
      vagrant scp $rpm :$(basename $rpm)
    done

    # Install each rpm
    vagrant ssh -- -L8081:localhost:8081 -L1338:localhost:1338
    sudo yum install -y *.rpm

### Released

    vagrant ssh -- -L8081:localhost:8081 -L1338:localhost:1338
    version=0.12.0
    pkg_root="https://apache.bintray.com/aurora/centos-7/"
    for rpm in \
        aurora-scheduler-${version}-1.el7.centos.aurora.x86_64.rpm \
        aurora-executor-${version}-1.el7.centos.aurora.x86_64.rpm \
        aurora-tools-${version}-1.el7.centos.aurora.x86_64.rpm; do
      wget $pkg_root/$rpm
      sudo yum install -y $rpm
    done

## Initialize and start


    sudo -u aurora mkdir -p /var/lib/aurora/scheduler/db
    sudo -u aurora mesos-log initialize --path=/var/lib/aurora/scheduler/db
    sudo systemctl start aurora
    sudo systemctl start thermos-observer

## Create a job

    echo "
    task = SequentialTask(
      processes = [Process(name = 'hello', cmdline = 'echo hello')],
      resources = Resources(cpu = 0.5, ram = 128*MB, disk = 128*MB))
    jobs = [Service(
      task = task, cluster = 'main', role = 'vagrant', environment = 'prod', name = 'hello')]" > hello_world.aurora

    aurora job create main/vagrant/prod/hello hello_world.aurora

## Troubleshooting

* Mesos: `/var/log/mesos`
* Aurora scheduler: `sudo journalctl -u aurora`
* Aurora observer: `sudo journalctl -u thermos-observer`
