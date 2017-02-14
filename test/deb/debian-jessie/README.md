# Installing Aurora

## Testing packages

Two methods are described, one for installing locally built packages, the other
for installing released packages or release candidate packages.


### Locally built

Run this from the toplevel repository:

    ./test/test-artifact.sh test/deb/debian-jessie /repo/artifacts/aurora-debian-jessie/dist


### Released

Run this from the toplevel repository:

    version=0.17.0
    pkg_root="https://apache.bintray.com/aurora/debian-jessie/"

    for deb in \
        aurora-scheduler_${version}_amd64.deb \
        aurora-executor_${version}_amd64.deb \
        aurora-tools_${version}_amd64.deb; do

      wget $pkg_root/$deb -P artifacts/aurora-debian-jessie/${version}
    done

    ./test/test-artifact.sh test/deb/debian-jessie /repo/artifacts/aurora-debian-jessie/${version}

## Troubleshooting

* Mesos: `/var/log/mesos`
* Aurora scheduler: `sudo journalctl -u aurora-scheduler`
* Aurora observer: `sudo journalctl -u thermos`
