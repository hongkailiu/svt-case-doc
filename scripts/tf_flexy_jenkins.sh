#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

readonly TF_BIN=/data/jenkins_home/my-tool/terraform
${TF_BIN} --version
${TF_BIN} init ./svt-case-doc/files/terraform/4_node_cluster/
${TF_BIN} apply -auto-approve -var-file="/data/secret/secret.tfvars" ./svt-case-doc/files/terraform/4_node_cluster/

sleep 60
export terraform_tf_state_file=$(readlink -f ./terraform.tfstate)
ls -al ${terraform_tf_state_file}

export ANSIBLE_HOST_KEY_CHECKING=False

rm -rfv ./openshift-ansible
git clone https://github.com/openshift/openshift-ansible.git
git -C ./openshift-ansible checkout release-3.11


readonly OCPTF_DIR=/data/jenkins_home/my-tool/ocptf
${OCPTF_DIR}/build/ocptf --list
ansible-playbook -i "${OCPTF_DIR}/build/ocptf" -i "${OCPTF_DIR}/test_files/ocpft/inv/2.file" "${OCPTF_DIR}/test_files/ocpft/playbook/test.yaml" --extra-vars "ansible_ssh_private_key_file=/data/secret/id_rsa_perf"

source /data/secret/secret.sh
ansible-playbook -i "${OCPTF_DIR}/build/ocptf" -i "${OCPTF_DIR}/test_files/ocpft/inv/2.file" ./openshift-ansible/playbooks/prerequisites.yml  --extra-vars "ansible_ssh_private_key_file=/data/secret/id_rsa_perf"
ansible-playbook -i "${OCPTF_DIR}/build/ocptf" -i "${OCPTF_DIR}/test_files/ocpft/inv/2.file" ./openshift-ansible/playbooks/deploy_cluster.yml --extra-vars "ansible_ssh_private_key_file=/data/secret/id_rsa_perf"
