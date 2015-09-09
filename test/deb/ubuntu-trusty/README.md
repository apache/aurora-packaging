# Installing Aurora
## Fetch and install packages

    version=0.9.0
    pkg_root="http://people.apache.org/~wfarner/aurora/distributions/$version/deb/ubuntu-trusty"
    for deb in \
        aurora-scheduler_${version}_amd64.deb \
        aurora-executor_${version}_amd64.deb \
        aurora-tools_${version}_amd64.deb; do
      wget $pkg_root/$deb
      sudo dpkg -i $deb
    done

The scheduler and observer will automatically start when installed.

## Initialize scheduler's replicated log

    sudo stop aurora-scheduler
    sudo -u aurora mkdir -p /var/lib/aurora/scheduler/db
    sudo -u aurora mesos-log initialize --path=/var/lib/aurora/scheduler/db
    sudo start aurora-scheduler

## Create a job

    echo "
    task = SequentialTask(
      processes = [Process(name = 'hello', cmdline = 'echo hello')],
      resources = Resources(cpu = 1.0, ram = 128*MB, disk = 128*MB))

    jobs = [Service(
      task = task, cluster = 'example', role = 'www-data', environment = 'prod', name = 'hello')]" > hello_world.aurora
    aurora job create example/www-data/prod/hello hello_world.aurora

## Logs
* scheduler: `/var/log/upstart/aurora-scheduler.log`
* observer: `/var/log/upstart/thermos.log`
