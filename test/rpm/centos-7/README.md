# Installing Aurora

## Install packages

# Within vagrant install vagrant scp
vagrant plugin install vagrant-scp

# Then scp over the newly built packages
vagrant scp \
    ~/aurora-packaging/artifacts/aurora-centos-7/dist/rpmbuild/SRPMS/aurora-scheduler-0.12.0-1.el7.centos.aurora.src.rpm \
    aurora_centos_7:aurora-scheduler-0.12.0-1.el7.centos.aurora.src.rpm

# Install each rpm via rpm –ivh aurora-scheduler-0.12.0-1.el7.centos.aurora.src.rpm

### Initialize and start

    sudo -u aurora mesos-log initialize --path=/var/lib/aurora/scheduler/db
    sudo systemctl start aurora

The second command alters the ZooKeeper path that the mesos distribution registers at.

## Create a job

    echo "
    task = SequentialTask(
      processes = [Process(name = 'hello', cmdline = 'echo hello')],
      resources = Resources(cpu = 1.0, ram = 128*MB, disk = 128*MB))

    jobs = [Service(
      task = task, cluster = 'main', role = 'www-data', environment = 'prod', name = 'hello')]" > hello_world.aurora
    aurora job create main/www-data/prod/hello hello_world.aurora
