#!/bin/bash

### before running the following script, make sure both your pull secret and `~/.docker/config.json` 
### contain the auth entries for
### 1. registry.svc.ci.openshift.org
### 2. quay.io
### Otherwise, check how2 here:
### https://github.com/hongkailiu/svt-case-doc/blob/master/ocp_4.0/ocp_4.0.md#aos-puddles
### https://github.com/hongkailiu/svt-case-doc/blob/master/ocp_4.0/next_gen_installer.md#installer-091-20190109
### Also make sure the auth token is up to date for `registry.svc.ci.openshift.org`.
### HOW to verify if the tokens are still valid: Just try to pull images
### docker pull quay.io/openshift-release-dev/ocp-v4.0-art-dev:v4.0.0-0.131.0.0-ose-installer
### docker pull registry.svc.ci.openshift.org/ocp/release:4.0.0-0.nightly-2019-01-29-025207
### Do NOT `oc logout` on the jump node which will expire the token

### Find the nightly build number: https://openshift-release.svc.ci.openshift.org/

# curl -LO https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/scripts/my_installer.sh
# bash ./my_installer.sh <4.0.0-0.nightly-2019-01-29-025207>

set -o errexit
set -o nounset
set -o pipefail

if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

INSTALL_FOLDER=$(date '+%Y%m%d_%H%M%S')
mkdir ${INSTALL_FOLDER}
echo "INSTALL_FOLDER: ${INSTALL_FOLDER}"

readonly BUILD_VERSION=$1
echo "${BUILD_VERSION}" >> "${INSTALL_FOLDER}/version.txt"
readonly IMAGE=$(oc adm release info --pullspecs registry.svc.ci.openshift.org/ocp/release:${BUILD_VERSION} | grep installer | awk '{print $2}')
readonly ID=$(docker create ${IMAGE})
docker cp ${ID}:/usr/bin/openshift-install "./${INSTALL_FOLDER}/"
docker rm ${ID}
echo "using the installer bin from IMAGE: ${IMAGE}"
echo "installer version: $(./${INSTALL_FOLDER}/openshift-install version)"

echo "Continue installation with the following commands:"
echo "export OPENSHIFT_INSTALL_RELEASE_IMAGE_OVERRIDE=registry.svc.ci.openshift.org/ocp/release:${BUILD_VERSION}"
echo "export _OPENSHIFT_INSTALL_RELEASE_IMAGE_OVERRIDE=registry.svc.ci.openshift.org/ocp/release:${BUILD_VERSION}"
echo "./${INSTALL_FOLDER}/openshift-install create install-config --dir=./${INSTALL_FOLDER}"
echo "./${INSTALL_FOLDER}/openshift-install create cluster --dir=./${INSTALL_FOLDER}"
