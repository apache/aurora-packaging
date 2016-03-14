# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

CURRENT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

TOPDIR ?= /scratch/src
DIST_DIR ?= /dist
RPM_TOPDIR ?= $(DIST_DIR)

DATETIME ?= $(shell date +%Y%m%d%H%M)

AURORA_VERSION ?= $(shell cat $(TOPDIR)/.auroraversion | tr '-' '.')
MESOS_VERSION ?= $(shell tr -d "'\" \t" < $(TOPDIR)/3rdparty/python/BUILD | sed -n 's/MESOS_REV=\(.*\)/\1/p' )

SOURCE_TARGET ?= $(RPM_TOPDIR)/rpmbuild/SOURCES/$(AURORA_VERSION).tar.gz

PHONY: all nightly_version release_version get_source_target clean mkdir srpm nightly_srpm nightly_rpm release_srpm release_rpm tar_source

all: release_rpm

nightly_version:
	$(eval AURORA_VERSION := $(AURORA_VERSION).$(DATETIME))

release_version:
	$(eval AURORA_VERSION := $(AURORA_VERSION))

clean:
	rm -rf $(RPM_TOPDIR)/rpmbuild

mkdir: clean
	mkdir -p $(RPM_TOPDIR)/rpmbuild/BUILD
	mkdir -p $(RPM_TOPDIR)/rpmbuild/BUILDROOT
	mkdir -p $(RPM_TOPDIR)/rpmbuild/RPMS
	mkdir -p $(RPM_TOPDIR)/rpmbuild/SOURCES
	mkdir -p $(RPM_TOPDIR)/rpmbuild/SRPMS
	cp /src.tar.gz $(SOURCE_TARGET)
	cp SOURCES/* $(RPM_TOPDIR)/rpmbuild/SOURCES

srpm: mkdir
	rpmbuild $(RPM_OPTS) \
		--define "_topdir $(RPM_TOPDIR)" \
		--define "_builddir %{_topdir}/rpmbuild/BUILD" \
		--define "_buildrootdir %{_topdir}/rpmbuild/BUILDROOT" \
		--define "_rpmdir %{_topdir}/rpmbuild/RPMS" \
		--define "_srcrpmdir %{_topdir}/rpmbuild/SRPMS" \
		--define "_specdir %(pwd)" \
		--define "_sourcedir  %{_topdir}/rpmbuild/SOURCES" \
		--define "AURORA_VERSION $(AURORA_VERSION)" \
		--define "MESOS_VERSION $(MESOS_VERSION)" \
		--nodeps -bs aurora.spec

rpm: mkdir
	rpmbuild $(RPM_OPTS) \
		--define "_topdir $(RPM_TOPDIR)" \
		--define "_builddir %{_topdir}/rpmbuild/BUILD" \
		--define "_buildrootdir %{_topdir}/rpmbuild/BUILDROOT" \
		--define "_rpmdir %{_topdir}/rpmbuild/RPMS" \
		--define "_srcrpmdir %{_topdir}/rpmbuild/SRPMS" \
		--define "_specdir %(pwd)" \
		--define "_sourcedir  %{_topdir}/rpmbuild/SOURCES" \
		--define "AURORA_VERSION $(AURORA_VERSION)" \
		--define "MESOS_VERSION $(MESOS_VERSION)" \
		-ba aurora.spec

nightly_srpm: nightly_version srpm

nightly_rpm: nightly_version rpm

release_srpm: release_version srpm

release_rpm: release_version rpm
