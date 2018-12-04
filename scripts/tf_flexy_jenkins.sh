#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

### assume
### 1. this script is at /home/fedora and ${GOPATH}=/home/fedora/go and perf key is /home/fedora/id_rsa_perf
### 2. ~/Downloads/secret.sh has the inv vars required by the playbook
### 3. /home/fedora/svt-case-doc (with valid secret.tfvars)


rm -rfv ./openshift-ansible
git clone https://github.com/openshift/openshift-ansible.git
git -C ./openshift-ansible checkout release-3.11

readonly TF_BIN=/data/jenkins_home/my-tool/terraform

${TF_BIN} --version
