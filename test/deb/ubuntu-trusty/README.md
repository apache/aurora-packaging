# Installing Aurora

## Testing packages

Two methods are described, one for installing locally built packages, the other
for installing released packages or release candidate packages.


### Locally built

Run this from the toplevel repository:

    ./test/test-artifact.sh test/deb/ubuntu-trusty /repo/artifacts/aurora-ubuntu-trusty/dist


### Released

Run this from the toplevel repository:

    version=0.17.0
    pkg_root="https://apache.bintray.com/aurora/ubuntu-trusty/"

    for deb in \
        aurora-scheduler_${version}_amd64.deb \
        aurora-executor_${version}_amd64.deb \
        aurora-tools_${version}_amd64.deb; do

      wget $pkg_root/$deb -P artifacts/aurora-ubuntu-trusty/${version}
    done

    ./test/test-artifact.sh test/deb/ubuntu-trusty /repo/artifacts/aurora-ubuntu-trusty/${version}


## Troubleshooting

* Mesos: `/var/log/mesos`
* Aurora scheduler: `/var/log/upstart/aurora-scheduler.log`
* Aurora observer: `/var/log/upstart/thermos.log`
