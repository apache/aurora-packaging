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
FROM debian:jessie-backports

WORKDIR /aurora
ENV HOME /aurora
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get -y install \
  bison \
  debhelper \
  devscripts \
  dpkg-dev \
  curl \
  git \
  libapr1-dev \
  libcurl4-openssl-dev \
  libkrb5-dev \
  libsvn-dev \
  python-all-dev \
  software-properties-common \
  thrift-compiler

RUN apt-get -y -t jessie-backports install openjdk-8-jdk \
   && update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java

# TODO (shirchen): explore possiblity of downloading gradle directly from gradle. Issue is that
# there's already a build-time dep of a package name 'gradle'.
# Install gradle.
RUN git clone --depth 1 https://github.com/benley/gradle-packaging \
  && cd gradle-packaging \
  && apt-get install -y ruby ruby-dev unzip wget \
  && gem install fpm && ./gradle-mkdeb.sh 2.10 \
  && dpkg -i gradle-2.10_2.10-2_all.deb \
  && cd .. && rm -rf gradle-packaging

ADD build.sh /build.sh
ADD pants.ini /pants.ini
