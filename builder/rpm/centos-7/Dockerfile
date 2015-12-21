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
FROM centos:7

RUN yum update -y
RUN yum install -y \
    make \
    rpm-build \
    yum-utils \
    apr-devel \
    cyrus-sasl-devel \
    flex \
    gcc \
    gcc-c++ \
    git \
    java-1.8.0-openjdk-devel \
    krb5-devel \
    libcurl-devel \
    openssl \
    patch \
    python \
    python-devel \
    subversion-devel \
    tar \
    unzip \
    wget \
    which \
    zlib-devel

ADD build.sh /build.sh
ADD pants.ini /pants.ini
