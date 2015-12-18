## Packaging for Apache Aurora

This repository maintains configuration and tooling for building binary
distributions of [Apache Aurora](https://aurora.apache.org/).

### Building a binary

Binaries are built within Docker containers that provide the appropriate build
environment for the target platform.  You will need to have a working Docker
installation before proceeding.

1. Fetch a source distribution, such as an [official one](https://aurora.apache.org/downloads/).
   Alternatively, you can also build from an arbitrary git commit by instead preparing sources
from the Aurora source repository:

        git archive --prefix=apache-aurora-$(cat .auroraversion)/ -o snapshot.tar.gz HEAD

2. Run the builder script, providing the distribution platform and the source
   distribution archive you downloaded in (1).  The example below will build
   Aurora 0.9.0 debs for Ubuntu Trusty.

        ./build-artifact.sh builder/deb/ubuntu-trusty \
          ../apache-aurora-0.9.0.tar.gz \
          0.9.0

When this completes, debs will be placed in `dist/builder/deb/ubuntu-trusty/`.

### Adding a new distribution platform

There are only two requirements for a 'builder' to satisfy:

- a `Dockerfile` to provide the repeatable build environment
- a `build.sh` script that creates artifacts

Please see the makeup of other builders for examples.
