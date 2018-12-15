#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

readonly VAR_FILE_NAME="./var_file_${BUILD_NUMBER}.tfvars"
curl -L ${my_var_file} -o "${VAR_FILE_NAME}"
readonly OCPTF_STATIC_INVENTORY="./2_${BUILD_NUMBER}.file"
curl -L ${static_ocp_inventory} -o "${OCPTF_STATIC_INVENTORY}"
echo "======"
cat "${VAR_FILE_NAME}"
echo ""
echo "======"

readonly TF_BIN=/data/jenkins_home/my-tool/terraform
${TF_BIN} --version
${TF_BIN} init ./svt-case-doc/files/terraform/4_node_cluster/
${TF_BIN} apply -auto-approve -var-file="/data/secret/secret.tfvars" -var-file="${VAR_FILE_NAME}" ./svt-case-doc/files/terraform/4_node_cluster/
mv -v ./terraform.tfstate "./terraform_${BUILD_NUMBER}.tfstate"

sleep 60
export terraform_tf_state_file=$(readlink -f "./terraform_${BUILD_NUMBER}.tfstate")
ls -al "${terraform_tf_state_file}"

export ANSIBLE_HOST_KEY_CHECKING=False

rm -rfv ./openshift-ansible
git clone https://github.com/openshift/openshift-ansible.git
git -C ./openshift-ansible checkout release-3.11


readonly OCPTF_DIR=/data/jenkins_home/my-tool/ocptf
readonly OCPTF_DYNAMIC_INVENTORY="./ocptf_${BUILD_NUMBER}.file"
install_ocp_gluster=false ${OCPTF_DIR}/build/ocptf --list --static > "${OCPTF_DYNAMIC_INVENTORY}"
echo "======"
cat "${OCPTF_DYNAMIC_INVENTORY}"
echo ""
echo "======"

ansible-playbook -i "${OCPTF_DYNAMIC_INVENTORY}" -i "${OCPTF_STATIC_INVENTORY}" "${OCPTF_DIR}/test_files/ocpft/playbook/test.yaml" --extra-vars "ansible_ssh_private_key_file=/data/secret/id_rsa_perf"

source /data/secret/secret.sh
ansible-playbook -i "${OCPTF_DYNAMIC_INVENTORY}" -i "${OCPTF_STATIC_INVENTORY}" ./openshift-ansible/playbooks/prerequisites.yml  --extra-vars "ansible_ssh_private_key_file=/data/secret/id_rsa_perf"
ansible-playbook -i "${OCPTF_DYNAMIC_INVENTORY}" -i "${OCPTF_STATIC_INVENTORY}" ./openshift-ansible/playbooks/deploy_cluster.yml --extra-vars "ansible_ssh_private_key_file=/data/secret/id_rsa_perf"
