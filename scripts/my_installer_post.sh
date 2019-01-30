#!/bin/bash

### create a jump node inside cluster VPC
### with the same security group and subnet
### the jump node uses `ami-0f7e779f5a384f9fc` (clean fedora 29) which is at us-east-2
### 1. Your aws account has to set the default profile to REGION us-east-2 for this script to work
### 2. `pip install awscli` if not yet
### 3. It is ASSSUMED that the libra key is used for 4.0 OCP cluster
####################################################################################
### REMEMBER to terminate this instance of jump node BEFORE destroy your cluster

### curl -LO https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/scripts/my_installer_post.sh
### bash ./my_installer_post.sh

set -o errexit
set -o nounset
set -o pipefail

####################################################################################
### CHANGE those vars
readonly KERBEROS_ID='hongkliu'
readonly PRIVATE_KEY="${HOME}/.ssh/libra.pem"

echo "creating cluster info ..."
readonly MASTER_PRIVATE_IP=$(oc get node | grep master | head -n 1 | awk '{print $1}')
echo "MASTER_PRIVATE_IP: ${MASTER_PRIVATE_IP}"

readonly SUBNET_ID=$(aws ec2 describe-instances --output json --filters "Name=private-dns-name,Values=${MASTER_PRIVATE_IP}"  | jq -r '.Reservations[].Instances[].SubnetId')
echo "SUBNET_ID: ${SUBNET_ID}"

readonly SECURITY_GROUP_ID=$(aws ec2 describe-instances --output json --filters "Name=private-dns-name,Values=${MASTER_PRIVATE_IP}"  | jq -r '.Reservations[].Instances[].SecurityGroups[].GroupId')
echo "SECURITY_GROUP_ID: ${SECURITY_GROUP_ID}"

echo "creating a jump node ..."
readonly INSTANCE_ID=$(aws ec2 run-instances --image-id ami-0f7e779f5a384f9fc --security-group-ids "${SECURITY_GROUP_ID}" --count 1    --associate-public-ip-address \
      --instance-type m5.xlarge --subnet "${SUBNET_ID}"  --key-name libra  --query 'Instances[*].InstanceId'  \
      --tag-specifications="[{\"ResourceType\":\"instance\",\"Tags\":[{\"Key\":\"Name\",\"Value\":\"qe-${KERBEROS_ID}-ocp-jn\"}]}]" | grep "i-" | tr -d '"' | tr -d " ")
echo "INSTANCE_ID: ${INSTANCE_ID}" 

echo "sleep 20 secs, waiting for the host is ready"
sleep 20

readonly PUBLIC_DNS_NAME=$(aws ec2 describe-instances --output json --instance-ids "${INSTANCE_ID}" | jq -r '.Reservations[].Instances[].PublicDnsName')
echo "PUBLIC_DNS_NAME: ${PUBLIC_DNS_NAME}" 

### allow ssh via root (optional)
### ssh -i ~/.ssh/libra.pem -o UserKnownHostsFile=/dev/null -n fedora@ec2-18-224-51-162.us-east-2.compute.amazonaws.com 'sudo cp ~/.ssh/authorized_keys /root/.ssh/authorized_keys'

###
ssh -i "${PRIVATE_KEY}" -o UserKnownHostsFile=/dev/null -n "fedora@${PUBLIC_DNS_NAME}" 'mkdir -p ~/.kube'
scp -i "${PRIVATE_KEY}" -o UserKnownHostsFile=/dev/null ~/.kube/config "fedora@${PUBLIC_DNS_NAME}:~/.kube/config"


ssh -i "${PRIVATE_KEY}" -o UserKnownHostsFile=/dev/null -n fedora@${PUBLIC_DNS_NAME} 'sudo dnf install -y origin-clients'
# OR
#ssh -i ~/.ssh/libra.pem -o UserKnownHostsFile=/dev/null -n fedora@ec2-18-224-51-162.us-east-2.compute.amazonaws.com 'mkdir -p ~/bin'
#scp -i ~/.ssh/libra.pem -o UserKnownHostsFile=/dev/null ~/bin/oc fedora@ec2-18-224-51-162.us-east-2.compute.amazonaws.com:~/bin/oc

scp -i "${PRIVATE_KEY}" -o UserKnownHostsFile=/dev/null "${PRIVATE_KEY}" fedora@${PUBLIC_DNS_NAME}:~/.ssh/id_rsa

echo "ssh to ${PUBLIC_DNS_NAME}: ssh -i ${PRIVATE_KEY} -o UserKnownHostsFile=/dev/null fedora@${PUBLIC_DNS_NAME}"
echo "run: oc get node"
echo "ssh core@<worker> should be working too on ${PUBLIC_DNS_NAME}"
