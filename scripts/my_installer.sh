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

### if file found: ${HOME}/install-config.yaml
### then it will be used for installation
### else copy/paste the commands from the output to proceed the installation

### Do NOT `oc logout` on the jump node which will expire the token
### @pruan: DO NOT PASTE the pull scecret dirtly from try.openshift.com

### Find the nightly build number: https://openshift-release.svc.ci.openshift.org/

# curl -LO https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/scripts/my_installer.sh
# bash ./my_installer.sh <4.0.0-0.nightly-2019-01-29-025207>
### OR
# bash ./my_installer.sh <quay.io/openshift-release-dev/ocp-release:4.0.0-0.10>

set -o errexit
set -o nounset
set -o pipefail

if [[ "$#" -ne 1 ]]; then
    echo "Illegal number of parameters"
    exit 1
fi

if [[ $1 == *":"* ]]; then
  echo "$1 contains :, use it as release image"
  release_image=$1
else
  echo "$1 contains no :, use it as release image tag"
  release_image="registry.svc.ci.openshift.org/ocp/release:$1"
fi

INSTALL_FOLDER=$(date '+%Y%m%d_%H%M%S')
mkdir ${INSTALL_FOLDER}
echo "INSTALL_FOLDER: ${INSTALL_FOLDER}"
echo "release_image: ${release_image}"
echo "release_image: ${release_image}" >> "${INSTALL_FOLDER}/version.txt"

installer_image=$(oc adm release info --image-for=installer "${release_image}")
echo "INSTALLER_IMAGE: ${installer_image}" >> "${INSTALL_FOLDER}/version.txt"
echo "using the installer bin from IMAGE: ${installer_image}"

### the following command will overwrite ./openshift-install
oc image extract ${installer_image} --file  /usr/bin/openshift-install
mv openshift-install "${INSTALL_FOLDER}/"
chmod +x "${INSTALL_FOLDER}/openshift-install"

echo "installer version: $(./${INSTALL_FOLDER}/openshift-install version)"

readonly INSTALL_CONFIG="${HOME}/install-config.yaml"

if [[ ! -f "${INSTALL_CONFIG}" ]]; then
  echo "File not found: ${INSTALL_CONFIG}"
  echo "Continue installation with the following commands:"
  echo "export OPENSHIFT_INSTALL_RELEASE_IMAGE_OVERRIDE=${release_image}"
  echo "export _OPENSHIFT_INSTALL_RELEASE_IMAGE_OVERRIDE=${release_image}"
  echo "./${INSTALL_FOLDER}/openshift-install create install-config --dir=./${INSTALL_FOLDER}"
  echo "vi ./${INSTALL_FOLDER}/install-config.yaml"
  echo "./${INSTALL_FOLDER}/openshift-install create cluster --dir=./${INSTALL_FOLDER}"
  exit 0
else
  echo "found: ${INSTALL_CONFIG}, using it for installation ..."
  cp -v "${INSTALL_CONFIG}" ./"${INSTALL_FOLDER}"/
  export OPENSHIFT_INSTALL_RELEASE_IMAGE_OVERRIDE=${release_image}
  export _OPENSHIFT_INSTALL_RELEASE_IMAGE_OVERRIDE=${release_image}
  ./${INSTALL_FOLDER}/openshift-install create cluster --dir=./${INSTALL_FOLDER}
fi

