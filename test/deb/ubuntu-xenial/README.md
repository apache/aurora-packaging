# Installing Aurora

## Testing packages

Two methods are described, one for installing locally built packages, the other
for installing released packages or release candidate packages.


### Locally built

Run this from the toplevel repository:

    ./test/test-artifact.sh test/deb/ubuntu-xenial /repo/artifacts/aurora-ubuntu-xenial/dist


### Released

Run this from the toplevel repository:

    version=0.17.0
    pkg_root="https://apache.bintray.com/aurora/ubuntu-xenial/"

    for deb in \
        aurora-scheduler_${version}_amd64.deb \
        aurora-executor_${version}_amd64.deb \
        aurora-tools_${version}_amd64.deb; do

      wget $pkg_root/$deb -P artifacts/aurora-ubuntu-xenial/${version}
    done

    ./test/test-artifact.sh test/deb/ubuntu-xenial /repo/artifacts/aurora-ubuntu-xenial/${version}


## Troubleshooting

* Mesos: `/var/log/mesos`
* Aurora scheduler: `cat /var/log/syslog  | grep aurora-scheduler` and `sudo journalctl -u aurora-scheduler`
* Aurora observer: `sudo journalctl -u thermos`
