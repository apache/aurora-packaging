#!/bin/bash
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

set -ex

mkdir /scratch
cd /scratch

tar --strip-components 1 -C . -xf /src.tar.gz

cp -R /specs/debian .

# Xenial tries to convert init and upstart scripts before using systemd units.
# Avoid conflict by not including them for now.
rm ./debian/*.upstart ./debian/*.init

DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
CODENAME=$(lsb_release -cs | tr '[:upper:]' '[:lower:]')
THIRD_PARTY_REPO="https://svn.apache.org/repos/asf/aurora/3rdparty/"
THIRD_PARTY_REPO+="${DISTRO}/${CODENAME}64/python/"

# Place the link to the correct python egg into aurora-pants.ini
echo "[python-repos]" >> ./debian/aurora-pants.ini
echo "repos: ['third_party/', '${THIRD_PARTY_REPO}']" >> ./debian/aurora-pants.ini

export DEBFULLNAME='Apache Aurora'
export DEBEMAIL='dev@aurora.apache.org'

dch \
  --newversion $AURORA_VERSION \
  --package apache-aurora \
  --urgency medium \
  "Apache Aurora package builder <dev@aurora.apache.org> $(date -R)"
dch --release ''

dpkg-buildpackage -uc -b -tc

mkdir /dist
mv ../*.deb /dist
