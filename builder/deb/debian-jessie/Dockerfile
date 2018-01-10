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
FROM debian:jessie

WORKDIR /aurora
ENV HOME /aurora
ENV DEBIAN_FRONTEND noninteractive

# The default httpredir mirror is a common source for flaky docker builds.
# Use an explicit mirror instead (https://github.com/docker-library/buildpack-deps/issues/40)
RUN echo \
   'deb http://mirrors.kernel.org/debian/ jessie main\n \
    deb http://mirrors.kernel.org/debian/ jessie-updates main\n \
    deb http://mirrors.kernel.org/debian/ jessie-backports main\n \
    deb http://security.debian.org jessie/updates main\n' \
    > /etc/apt/sources.list

RUN apt-get update && apt-get -y install \
  bison \
  debhelper \
  dh-systemd \
  devscripts \
  dpkg-dev \
  curl \
  git \
  libapr1-dev \
  libcurl4-openssl-dev \
  libffi-dev \
  libkrb5-dev \
  libssl-dev \
  libsvn-dev \
  python-all-dev \
  software-properties-common

RUN apt-get -y -t jessie-backports install openjdk-8-jdk \
   && update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java

# TODO (shirchen): explore possiblity of downloading gradle directly from gradle. Issue is that
# there's already a build-time dep of a package name 'gradle'.
# Install gradle.
RUN git clone --depth 1 https://github.com/benley/gradle-packaging \
  && cd gradle-packaging \
  && apt-get -y install ruby ruby-dev unzip wget \
  && gem install fpm && ./gradle-mkdeb.sh 4.2 \
  && apt-get -y install gdebi-core \
  && gdebi --non-interactive gradle-4.2_4.2-2_all.deb \
  && cd .. && rm -rf gradle-packaging

ADD build.sh /build.sh
