# Installing Aurora

## Install packages
### Point to wfarner's test yum repo

    echo '[apache-aurora-wfarner]
    name=Apache Aurora distribution maintained by wfarner
    baseurl=http://people.apache.org/~wfarner/aurora/distributions/0.9.0/rpm/centos-7/x86_64/
    gpgcheck = 0' | sudo tee /etc/yum.repos.d/apache-aurora-wfarner.repo > /dev/null

## Install

    sudo yum install -y aurora aurora-client aurora-thermos

### Initialize and start

    sudo -u aurora mesos-log initialize --path=/var/lib/aurora/db
    sudo sed -i 's|zk://127.0.0.1:2181/mesos/master|zk://127.0.0.1:2181/mesos|g' /etc/sysconfig/aurora
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
