# Installing Aurora

## Testing packages

Two methods are described, one for installing locally built packages, the other
for installing released packages or release candidate packages.


### Locally built

Run this from the toplevel repository:

    ./test/test-artifact.sh test/rpm/centos-7 /repo/artifacts/aurora-centos-7/dist/rpmbuild/RPMS/x86_64


### Released

Run this from the toplevel repository:

    version=0.17.0
    pkg_root="https://apache.bintray.com/aurora/centos-7/"

    for rpm in \
        aurora-scheduler-${version}-1.el7.centos.aurora.x86_64.rpm \
        aurora-executor-${version}-1.el7.centos.aurora.x86_64.rpm \
        aurora-tools-${version}-1.el7.centos.aurora.x86_64.rpm; do

      wget $pkg_root/$rpm -P artifacts/aurora-centos-7/${version}
    done

    ./test/test-artifact.sh test/rpm/centos-7 /repo/artifacts/aurora-centos-7/${version}


## Troubleshooting

* Mesos: `/var/log/mesos`
* Aurora scheduler: `sudo journalctl -u aurora-scheduler`
* Aurora observer: `sudo journalctl -u thermos`
