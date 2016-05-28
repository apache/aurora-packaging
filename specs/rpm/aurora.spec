#
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
#

# Overridable variables;
%if %{?!AURORA_VERSION:1}0
%global AURORA_VERSION 0.13.0
%endif

%if %{?!AURORA_INTERNAL_VERSION:1}0
%global AURORA_INTERNAL_VERSION %{AURORA_VERSION}
%endif

%if %{?!AURORA_USER:1}0
%global AURORA_USER aurora
%endif

%if %{?!AURORA_GROUP:1}0
%global AURORA_GROUP aurora
%endif

%if %{?!GRADLE_BASEURL:1}0
%global GRADLE_BASEURL https://services.gradle.org/distributions
%endif

%if %{?!GRADLE_VERSION:1}0
%global GRADLE_VERSION 2.12
%endif

%if %{?!JAVA_VERSION:!}0
%global JAVA_VERSION 1.8.0
%endif

%if %{?!MESOS_VERSION:1}0
%global MESOS_VERSION 0.26.0
%endif

%if %{?!PEX_BINARIES:1}0
%global PEX_BINARIES aurora aurora_admin thermos thermos_executor thermos_runner thermos_observer
%endif

%if %{?!PYTHON_VERSION:1}0
%global PYTHON_VERSION 2.7
%endif


Name:          aurora-scheduler
Version:       %{AURORA_VERSION}
Release:       1%{?dist}.aurora
Summary:       A Mesos framework for scheduling and executing long-running services and cron jobs.
Group:         Applications/System
License:       ASL 2.0
URL:           https://aurora.apache.org/

Source0:       http://www.apache.org/dyn/closer.cgi?action=download&filename=aurora/%{version}/apache-aurora-%{version}.tar.gz#/apache-aurora-%{version}.tar.gz
Source1:       aurora.service
Source2:       thermos-observer.service
Source3:       aurora.init.sh
Source4:       thermos-observer.init.sh
Source5:       aurora.startup.sh
Source6:       thermos-observer.startup.sh
Source7:       aurora.sysconfig
Source8:       thermos-observer.sysconfig
Source9:       aurora.logrotate
Source10:      thermos-observer.logrotate
Source11:      clusters.json
Source12:      aurora-pants.ini

BuildRequires: apr-devel
BuildRequires: cyrus-sasl-devel
BuildRequires: gcc
BuildRequires: gcc-c++
BuildRequires: git
BuildRequires: java-%{JAVA_VERSION}-openjdk-devel
BuildRequires: krb5-devel
BuildRequires: libcurl-devel
BuildRequires: openssl
BuildRequires: patch
%if 0%{?rhel} && 0%{?rhel} < 7
BuildRequires: python27
BuildRequires: python27-scldevel
%else
BuildRequires: python
BuildRequires: python-devel
%endif
BuildRequires: subversion-devel
BuildRequires: tar
BuildRequires: unzip
BuildRequires: wget
BuildRequires: zlib-devel

%if 0%{?rhel} && 0%{?rhel} < 7
Requires:      daemonize
%endif
Requires:      java-%{JAVA_VERSION}-headless
Requires:      mesos >= %{MESOS_VERSION}


%description
Apache Aurora is a service scheduler that runs on top of Mesos, enabling you to schedule
long-running services that take advantage of Mesos' scalability, fault-tolerance, and
resource isolation.


%package -n aurora-tools
Summary: A client for scheduling services against the Aurora scheduler
Group: Development/Tools

Requires: krb5-libs
%if 0%{?rhel} && 0%{?rhel} < 7
Requires: python27
%else
Requires: python
%endif

%description -n aurora-tools
A set of command-line applications used for interacting with and administering Aurora
schedulers.


%package -n aurora-executor
Summary: Mesos executor that runs and monitors tasks scheduled by the Aurora scheduler
Group: Applications/System

Requires: mesos >= %{MESOS_VERSION}
%if 0%{?rhel} && 0%{?rhel} < 7
Requires: python27
%else
Requires: python
%endif

%description -n aurora-executor
Thermos a simple process management framework used for orchestrating dependent processes
within a single Mesos chroot.  It works in tandem with Aurora to ensure that tasks
scheduled by it are properly executed on Mesos slaves and provides a Web UI to monitor the
state of all running tasks.


%prep
%setup -n apache-aurora-%{AURORA_INTERNAL_VERSION}

%build
# Preferences SCL-installed Python 2.7 if we're building on EL6.
%if 0%{?rhel} && 0%{?rhel} < 7
export PATH=/opt/rh/python27/root/usr/bin${PATH:+:${PATH}}
export LD_LIBRARY_PATH=/opt/rh/python27/root/usr/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
export MANPATH=/opt/rh/python27/root/usr/share/man:${MANPATH}
# For systemtap
export XDG_DATA_DIRS=/opt/rh/python27/root/usr/share${XDG_DATA_DIRS:+:${XDG_DATA_DIRS}}
# For pkg-config
export PKG_CONFIG_PATH=/opt/rh/python27/root/usr/lib64/pkgconfig${PKG_CONFIG_PATH:+:${PKG_CONFIG_PATH}}
%endif

# Preferences Java 1.8 over any other Java version.
export PATH=/usr/lib/jvm/java-1.8.0/bin:${PATH}

# Downloads Gradle executable.
wget %{GRADLE_BASEURL}/gradle-%{GRADLE_VERSION}-bin.zip
unzip gradle-%{GRADLE_VERSION}-bin.zip

# Builds the Aurora scheduler.
./gradle-%{GRADLE_VERSION}/bin/gradle installDist

# Configures pants to use our distributed platform-specific eggs.
# This avoids building mesos to produce them.
%{__mkdir_p} %{buildroot}
%{__cp} %{SOURCE12} %{buildroot}
export PANTS_CONFIG_OVERRIDE="['%{buildroot}/aurora-pants.ini']"

# Builds Aurora client PEX binaries.
./pants binary src/main/python/apache/aurora/kerberos:kaurora
mv dist/kaurora.pex dist/aurora.pex
./pants binary src/main/python/apache/aurora/kerberos:kaurora_admin
mv dist/kaurora_admin.pex dist/aurora_admin.pex

# Builds Aurora Thermos and GC executor PEX binaries.
./pants binary src/main/python/apache/aurora/executor:thermos_executor
./pants binary src/main/python/apache/aurora/tools:thermos
./pants binary src/main/python/apache/aurora/tools:thermos_observer
./pants binary src/main/python/apache/thermos/runner:thermos_runner

# Packages the Thermos runner within the Thermos executor.
build-support/embed_runner_in_executor.py

%install
rm -rf $RPM_BUILD_ROOT

# Builds installation directory structure.
mkdir -p %{buildroot}%{_bindir}
mkdir -p %{buildroot}%{_docdir}/aurora-%{version}
mkdir -p %{buildroot}%{_prefix}/lib/aurora
mkdir -p %{buildroot}%{_sharedstatedir}
mkdir -p %{buildroot}%{_localstatedir}/lib/aurora
mkdir -p %{buildroot}%{_localstatedir}/log/aurora
mkdir -p %{buildroot}%{_localstatedir}/log/thermos
mkdir -p %{buildroot}%{_localstatedir}/run/thermos
mkdir -p %{buildroot}%{_sysconfdir}/aurora
mkdir -p %{buildroot}%{_sysconfdir}/init.d
mkdir -p %{buildroot}%{_sysconfdir}/systemd/system
mkdir -p %{buildroot}%{_sysconfdir}/logrotate.d
mkdir -p %{buildroot}%{_sysconfdir}/sysconfig

# Installs the Aurora scheduler that was just built into /usr/lib/aurora.
cp -r dist/install/aurora-scheduler/* %{buildroot}%{_prefix}/lib/aurora

# Installs all PEX binaries.
for pex_binary in %{PEX_BINARIES}; do
  install -m 755 dist/${pex_binary}.pex %{buildroot}%{_bindir}/${pex_binary}
done

# Installs all support scripting.
%if 0%{?fedora} || 0%{?rhel} > 6
install -m 644 %{SOURCE1} %{buildroot}%{_sysconfdir}/systemd/system
install -m 644 %{SOURCE2} %{buildroot}%{_sysconfdir}/systemd/system/thermos-observer.service
%else
install -m 755 %{SOURCE3} %{buildroot}%{_sysconfdir}/init.d/aurora
install -m 755 %{SOURCE4} %{buildroot}%{_sysconfdir}/init.d/thermos-observer
%endif

install -m 755 %{SOURCE5} %{buildroot}%{_bindir}/aurora-scheduler-startup
install -m 755 %{SOURCE6} %{buildroot}%{_bindir}/thermos-observer-startup

install -m 644 %{SOURCE7} %{buildroot}%{_sysconfdir}/sysconfig/aurora
install -m 644 %{SOURCE8} %{buildroot}%{_sysconfdir}/sysconfig/thermos-observer

install -m 644 %{SOURCE9} %{buildroot}%{_sysconfdir}/logrotate.d/aurora
install -m 644 %{SOURCE10} %{buildroot}%{_sysconfdir}/logrotate.d/thermos-observer

install -m 644 %{SOURCE11} %{buildroot}%{_sysconfdir}/aurora/clusters.json


%pre
getent group %{AURORA_GROUP} > /dev/null || groupadd -r %{AURORA_GROUP}
getent passwd %{AURORA_USER} > /dev/null || \
    useradd -r -d %{_localstatedir}/lib/aurora -g %{AURORA_GROUP} \
    -s /bin/bash -c "Aurora Scheduler" %{AURORA_USER}
exit 0

# Pre/post installation scripts:
%post
%if 0%{?fedora} || 0%{?rhel} > 6
%systemd_post aurora.service
%else
/sbin/chkconfig --add aurora
%endif

%preun
%if 0%{?fedora} || 0%{?rhel} > 6
%systemd_preun aurora.service
%else
/sbin/service aurora stop >/dev/null 2>&1
/sbin/chkconfig --del aurora
%endif

%postun
%if 0%{?fedora} || 0%{?rhel} > 6
%systemd_postun_with_restart aurora.service
%else
/sbin/service aurora start >/dev/null 2>&1
%endif


%post -n aurora-executor
%if 0%{?fedora} || 0%{?rhel} > 6
%systemd_post thermos-observer.service
%else
/sbin/chkconfig --add thermos-observer
%endif

%preun -n aurora-executor
%if 0%{?fedora} || 0%{?rhel} > 6
%systemd_preun thermos-observer.service
%else
/sbin/service thermos-observer stop >/dev/null 2>&1
/sbin/chkconfig --del thermos-observer
%endif

%postun -n aurora-executor
%if 0%{?fedora} || 0%{?rhel} > 6
%systemd_postun_with_restart thermos-observer.service
%else
/sbin/service thermos-observer start >/dev/null 2>&1
%endif


%files
%defattr(-,root,root,-)
%doc docs/*.md
%{_bindir}/aurora-scheduler-startup
%attr(-,%{AURORA_USER},%{AURORA_GROUP}) %{_localstatedir}/lib/aurora
%attr(-,%{AURORA_USER},%{AURORA_GROUP}) %{_localstatedir}/log/aurora
%{_prefix}/lib/aurora/bin/*
%{_prefix}/lib/aurora/etc/*
%{_prefix}/lib/aurora/lib/*
%if 0%{?fedora} || 0%{?rhel} > 6
%{_sysconfdir}/systemd/system/aurora.service
%else
%{_sysconfdir}/init.d/aurora
%endif
%config(noreplace) %{_sysconfdir}/logrotate.d/aurora
%config(noreplace) %{_sysconfdir}/sysconfig/aurora


%files -n aurora-tools
%defattr(-,root,root,-)
%{_bindir}/aurora
%{_bindir}/aurora_admin
%config(noreplace) %{_sysconfdir}/aurora/clusters.json


%files -n aurora-executor
%defattr(-,root,root,-)
%{_bindir}/thermos
%{_bindir}/thermos_executor
%{_bindir}/thermos_observer
%{_bindir}/thermos_runner
%{_bindir}/thermos-observer-startup
%{_localstatedir}/log/thermos
%{_localstatedir}/run/thermos
%if 0%{?fedora} || 0%{?rhel} > 6
%{_sysconfdir}/systemd/system/thermos-observer.service
%else
%{_sysconfdir}/init.d/thermos-observer
%endif
%config(noreplace) %{_sysconfdir}/logrotate.d/thermos-observer
%config(noreplace) %{_sysconfdir}/sysconfig/thermos-observer


%changelog
* Wed Dec 2 2015 Bill Farner <wfarner@apache.org> 0.10.0-1.el7
- Updated to Apache Aurora 0.10.0

* Mon Aug 31 2015 Bill Farner <wfarner@apache.org> 0.9.0-1.el7
- Apache Aurora 0.9.0
