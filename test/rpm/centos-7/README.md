# Installing Aurora

## Install packages

### Install vagrant scp

    vagrant plugin install vagrant-scp

### Then scp over the newly built packages

    for rpm in ../../../artifacts/aurora-centos-7/dist/rpmbuild/RPMS/x86_64/*.rpm; do
      vagrant scp $rpm aurora_centos_7:$(basename $rpm)
    done

### Install each rpm

    vagrant ssh -- -L8081:localhost:8081 -L1338:localhost:1338
    sudo yum install -y *.rpm

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
