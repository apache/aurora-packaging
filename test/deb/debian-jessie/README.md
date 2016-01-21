# Within vagrant install vagrant scp
vagrant plugin install vagrant-scp
# Then scp over the newly built packages
vagrant scp \
    ~/aurora-packaging/artifacts/aurora-debian-jessie/dist/aurora-scheduler_0.12.1.uber.3_amd64.deb \
    aurora_jessie:aurora-scheduler_0.12.1.uber.3_amd64.deb

# Install each deb via dpkg -i

# Start Mesos + ZK
sudo systemctl start mesos-master
sudo systemctl start mesos-slave
# Stop scheduler to setup log replication.
sudo systemctl stop aurora-scheduler

# Setup log replication
sudo chown -R aurora:aurora /var/lib/aurora
sudo -u aurora mesos-log initialize --path=/var/lib/aurora/scheduler/db

# Start Aurora scheduler again
sudo systemctl start aurora-scheduler

## Create a job

echo "
task = SequentialTask(
  processes = [Process(name = 'hello', cmdline = 'echo hello')],
  resources = Resources(cpu = 1.0, ram = 128*MB, disk = 128*MB))
jobs = [Service(
  task = task, cluster = 'example', role = 'www-data', environment = 'prod', name = 'hello')]" > hello_world.aurora

aurora job create example/www-data/prod/hello hello_world.aurora
