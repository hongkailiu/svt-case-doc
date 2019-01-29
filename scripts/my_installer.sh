#!/bin/bash

# curl -LO https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/scripts/my_installer.sh
# bash ./my_installer.sh <4.0.0-0.nightly-2019-01-29-025207>

set -o errexit
set -o nounset
set -o pipefail

if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters"
    exit 1
fi


readonly BUILD_VERSION=$1
readonly IMAGE=$(oc adm release info --pullspecs registry.svc.ci.openshift.org/ocp/release:${BUILD_VERSION} | grep installer | awk '{print $2}')
readonly ID=$(docker create ${IMAGE})
docker cp ${ID}:/usr/bin/openshift-install .
docker rm ${ID}
echo "installer version: $(./openshift-install version)"

echo "export OPENSHIFT_INSTALL_RELEASE_IMAGE_OVERRIDE=registry.svc.ci.openshift.org/ocp/release:${BUILD_VERSION}"
echo "export _OPENSHIFT_INSTALL_RELEASE_IMAGE_OVERRIDE=registry.svc.ci.openshift.org/ocp/release:${BUILD_VERSION}"
echo "./openshift-install create install-config"
