#!/bin/bash

### curl -LO https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/scripts/my_installer_ceph_attach_device.sh
### bash ./my_installer_ceph_attach_device.sh

set -o errexit
set -o nounset
set -o pipefail

readonly CLUSTER_NAME=hongkliu1
readonly AWS_ZONE=us-east-2c
readonly AWS_REGION=us-east-2

readonly NODES=( $(oc get machines.machine.openshift.io -n openshift-machine-api | grep worker | grep ${AWS_ZONE} | awk '{print $1}' | while read i; do oc get machines.machine.openshift.io -n openshift-machine-api $i -o json | jq -r .status.nodeRef.name; done) )
### readonly NODES=("one" "two" "three")

if [[ ${#NODES[@]} -ne 3 ]]; then
  echo "must have 3 nodes"
  exit 1
fi

for node in "${NODES[@]}"
do
  echo "node: ${node}"
done

readonly INSTANCES=( $(oc get machines.machine.openshift.io -n openshift-machine-api | grep worker | grep ${AWS_ZONE} | awk '{print $1}' | while read i; do oc get machines.machine.openshift.io -n openshift-machine-api $i -o json | jq -r .status.providerStatus.instanceId; done) )

for instance in "${INSTANCES[@]}"
do
  echo "instance: ${instance}"
done

readonly DEVICES=( $(for i in {1..3}; do aws ec2 create-volume --output json --size 1000 --region ${AWS_REGION} --availability-zone ${AWS_ZONE} --volume-type gp2 --tag-specifications="[{\"ResourceType\":\"volume\",\"Tags\":[{\"Key\":\"Name\",\"Value\":\"qe-${CLUSTER_NAME}-ceph-${i}\"}]}]" | jq -r .VolumeId; done) )

for device in "${DEVICES[@]}"
do
  echo "device: ${device}"
done

echo "wait 60 secs for devices availability ..."
sleep 60

echo "attaching devices to instances ..."
for i in {0..2}; do aws ec2 attach-volume --volume-id ${DEVICES[i]}  --instance-id ${INSTANCES[i]} --device /dev/sdf; done
