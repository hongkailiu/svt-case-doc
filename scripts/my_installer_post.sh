#!/bin/bash

### create a jump node: implementation of the following link
### https://github.com/openshift/training/blob/master/docs/03-explore.md#exploring-rhel-coreos
### the jump node uses `ami-0f7e779f5a384f9fc` (clean fedora 29) which is in US East (Ohio), ie, us-east-2
### 1. Your aws account has to set the default profile to REGION us-east-2 for this script to work
### 2. `pip install awscli` if not yet
### 3. It is ASSSUMED that the libra key is used for 4.0 OCP cluster
####################################################################################
### REMEMBER to terminate this instance of jump node and delete the created security group BEFORE destroy your cluster

### curl -LO https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/scripts/my_installer_post.sh
### bash ./my_installer_post.sh

set -o errexit
set -o nounset
set -o pipefail

####################################################################################
### CHANGE those vars
readonly KERBEROS_ID='hongkliu'
readonly CLUSTER_NAME='hongkliu1'
readonly PRIVATE_KEY="${HOME}/.ssh/libra.pem"

bye () {
	# shellcheck disable=SC2059
	printf "${@}" >&2
	exit 1
}

echo "creating cluster info ..."
MASTER_PRIVATE_IP="$(oc get node | grep master | head -n 1 | awk '{print $1}')" || bye 'failed to resolve MASTER_PRIVATE_IP\n'
echo "MASTER_PRIVATE_IP: ${MASTER_PRIVATE_IP}"

#RANDOM_ID="$(oc describe node $(oc get node --no-headers | head -n 1 | awk '{print $1}') | grep "${CLUSTER_NAME}" | awk '{print $3}' | awk -F'/' '{print $2}' |  awk -F'-' '{print $(NF-2)}')" || bye 'failed to resolve RANDOM_ID\n'
RANDOM_ID="$(oc describe node $(oc get node --no-headers | grep worker | head -n 1 | awk '{print $1}') | grep "${CLUSTER_NAME}" | awk '{print $3}' | awk -F'/' '{print $2}' |  awk -F'-' '{print $(NF-5)}')" || bye 'failed to resolve RANDOM_ID\n'
echo "RANDOM_ID: ${RANDOM_ID}"

#readonly SUBNET_ID=$(aws ec2 describe-instances --output json --filters "Name=private-dns-name,Values=${MASTER_PRIVATE_IP}"  | jq -r '.Reservations[].Instances[].SubnetId')
#readonly SUBNET_ID=$(aws ec2 describe-subnets --output json --filters "Name=tag:kubernetes.io/cluster/${CLUSTER_NAME},Values=owned" "Name=cidrBlock,Values=10.0.0.0/20" | jq -r '.Subnets[].SubnetId' | head -n 1)
SUBNET_ID="$(aws ec2 describe-subnets --output json --filters "Name=tag:kubernetes.io/cluster/${CLUSTER_NAME}-${RANDOM_ID},Values=owned" | jq -r --arg key "${CLUSTER_NAME}-${RANDOM_ID}-public" '.Subnets[] | select((.Tags[].Value | contains($key)) and (.Tags[].Value | endswith("a"))) | .SubnetId')" || bye 'failed to resolve SUBNET_ID\n'
echo "SUBNET_ID: ${SUBNET_ID}"

VCP_ID="$(aws ec2 describe-vpcs --output json --filters "Name=tag:kubernetes.io/cluster/${CLUSTER_NAME}-${RANDOM_ID},Values=owned" | jq -r .Vpcs[0].VpcId)" || bye 'failed to resolve VCP_ID\n'
echo "VCP_ID: ${VCP_ID}"

echo "creating a sg ..."
#readonly SECURITY_GROUP_ID=$(aws ec2 describe-instances --output json --filters "Name=private-dns-name,Values=${MASTER_PRIVATE_IP}"  | jq -r '.Reservations[].Instances[].SecurityGroups[].GroupId')
SECURITY_GROUP_ID="$(aws ec2 create-security-group --group-name "qe-${KERBEROS_ID}-${CLUSTER_NAME}-${RANDOM_ID}-ocp" --description "created by my_installer_post.sh" --vpc-id "${VCP_ID}" --query 'GroupId' | grep "sg-" | tr -d '"' | tr -d " ")" || bye 'failed to resolve SECURITY_GROUP_ID\n'
echo "SECURITY_GROUP_ID: ${SECURITY_GROUP_ID}"

echo "opening ssh port (22) in the sg ..."
aws ec2 authorize-security-group-ingress --group-id ${SECURITY_GROUP_ID} --protocol tcp --port 22 --cidr 0.0.0.0/0

echo "creating a jump node ..."
INSTANCE_ID="$(aws ec2 run-instances --image-id ami-0f7e779f5a384f9fc --security-group-ids "${SECURITY_GROUP_ID}" --count 1    --associate-public-ip-address \
      --instance-type m5.xlarge --subnet "${SUBNET_ID}"  --key-name libra  --query 'Instances[*].InstanceId'  \
      --tag-specifications="[{\"ResourceType\":\"instance\",\"Tags\":[{\"Key\":\"Name\",\"Value\":\"qe-${KERBEROS_ID}-${CLUSTER_NAME}-${RANDOM_ID}-ocp-jn\"}]}]" | grep "i-" | tr -d '"' | tr -d " ")" || bye 'failed to resolve INSTANCE_ID\n'
echo "INSTANCE_ID: ${INSTANCE_ID}" 

echo "sleep 20 secs, waiting for the host is ready"
sleep 20

readonly PUBLIC_DNS_NAME=$(aws ec2 describe-instances --output json --instance-ids "${INSTANCE_ID}" | jq -r '.Reservations[].Instances[].PublicDnsName')
echo "PUBLIC_DNS_NAME: ${PUBLIC_DNS_NAME}" 

### allow ssh via root (optional)
### ssh -i ~/.ssh/libra.pem -o UserKnownHostsFile=/dev/null -n fedora@ec2-18-224-51-162.us-east-2.compute.amazonaws.com 'sudo cp ~/.ssh/authorized_keys /root/.ssh/authorized_keys'

###
ssh -i "${PRIVATE_KEY}" -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -n "fedora@${PUBLIC_DNS_NAME}" 'mkdir -p ~/.kube'
scp -i "${PRIVATE_KEY}" -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ~/.kube/config "fedora@${PUBLIC_DNS_NAME}:~/.kube/config"


ssh -i "${PRIVATE_KEY}" -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -n fedora@${PUBLIC_DNS_NAME} 'sudo dnf install -y origin-clients'
# OR
### the following oc binary hit https://github.com/openshift/origin/issues/21061
### because the local oc is build for RHEL
#ssh -i "${PRIVATE_KEY}" -o UserKnownHostsFile=/dev/null -n fedora@${PUBLIC_DNS_NAME} 'mkdir -p ~/bin'
#scp -i "${PRIVATE_KEY}" -o UserKnownHostsFile=/dev/null ~/bin/oc fedora@${PUBLIC_DNS_NAME}:~/bin/oc

scp -i "${PRIVATE_KEY}" -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "${PRIVATE_KEY}" fedora@${PUBLIC_DNS_NAME}:~/.ssh/id_rsa

echo "ssh to ${PUBLIC_DNS_NAME}: ssh -i ${PRIVATE_KEY} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no fedora@${PUBLIC_DNS_NAME}"
echo "run: oc get node"
echo "ssh core@<worker> should be working too on ${PUBLIC_DNS_NAME}"
