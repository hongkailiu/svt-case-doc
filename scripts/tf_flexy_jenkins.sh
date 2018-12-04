#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

### assume
### 1. this script is at /home/fedora and ${GOPATH}=/home/fedora/go and perf key is /home/fedora/id_rsa_perf
### 2. ~/Downloads/secret.sh has the inv vars required by the playbook
### 3. /home/fedora/svt-case-doc (with valid secret.tfvars)

cd

rm -rfv /tmp/openshift-ansible
cd /tmp/
git clone https://github.com/openshift/openshift-ansible.git
cd openshift-ansible/
git checkout release-3.11

cd
cd svt-case-doc/files/terraform/4_node_cluster/
terraform init -var-file="secret.tfvars"
terraform apply -var-file="secret.tfvars" -auto-approve
sleep 60
export terraform_tf_state_file=$(readlink -f ./terraform.tfstate)
ls -al ${terraform_tf_state_file}

cd
export ANSIBLE_HOST_KEY_CHECKING=False

go get -u github.com/hongkailiu/test-go/cmd/ocptf
cd "${GOPATH}/src/github.com/hongkailiu/test-go/"
make build-ocptf
./build/ocptf --list
ansible-playbook -i ./build/ocptf -i ./test_files/ocpft/inv/2.file ./test_files/ocpft/playbook/test.yaml

source ~/Downloads/secret.sh
ansible-playbook -i build/ocptf -i test_files/ocpft/inv/2.file ~/openshift-ansible/playbooks/prerequisites.yml
ansible-playbook -i build/ocptf -i test_files/ocpft/inv/2.file ~/openshift-ansible/playbooks/deploy_cluster.yml

cd
