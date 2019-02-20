#!/bin/bash

### curl -LO https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/scripts/my_installer_ceph_attach_device.sh
### bash ./my_installer_ceph_attach_device.sh

set -o errexit
set -o nounset
set -o pipefail

readonly CLUSTER_NAME=hongkliu1
readonly AWS_ZONE=us-east-2c
readonly AWS_REGION=us-east-2

### # bash ./my_installer_ceph_attach_device.sh
### make sure 3 nodes for storage 
### oc get machinesets.machine.openshift.io ${CLUSTER_NAME}-worker-${AWS_ZONE}
### NAME                          DESIRED   CURRENT   READY   AVAILABLE   AGE
### hongkliu2-worker-us-east-2c   3         3         3       3           84m


readonly NODES=( $(oc get machines.machine.openshift.io -n openshift-machine-api | grep worker | grep ${AWS_ZONE} | awk '{print $1}' | while read i; do oc get machines.machine.openshift.io -n openshift-machine-api $i -o json | jq -r .status.nodeRef.name; done) )
### readonly NODES=("one" "two" "three")

if [[ ${#NODES[@]} -ne 3 ]]; then
  echo "must have 3 nodes"
  exit 1
fi

for node in "${NODES[@]}"; do echo "node: ${node}"; oc label node ${node} role=storage-node --overwrite; done

readonly TMP_DIR=/tmp/${CLUSTER_NAME}

rm -rvf ${TMP_DIR}
mkdir ${TMP_DIR}

git clone https://github.com/hongkailiu/rook.git ${TMP_DIR}/rook
git -C ${TMP_DIR}/rook checkout release-0.9-on-ocp-4

oc create -f ${TMP_DIR}/rook/cluster/examples/kubernetes/ceph/scc.yaml
oc create -f ${TMP_DIR}/rook/cluster/examples/kubernetes/ceph/operator.yaml

echo "sleep 60 sec"
sleep 60

oc get pod -n rook-ceph-system

oc create -f ${TMP_DIR}/rook/cluster/examples/kubernetes/ceph/cluster.yaml
oc get pod -n rook-ceph

oc create -f ${TMP_DIR}/rook/cluster/examples/kubernetes/ceph/filesystem.yaml
oc -n rook-ceph get pod -l app=rook-ceph-mds

oc create -f ${TMP_DIR}/rook/cluster/examples/kubernetes/ceph/toolbox.yaml
oc -n rook-ceph get pod -l "app=rook-ceph-tools"

oc rsh -n rook-ceph $(oc -n rook-ceph get pod -l "app=rook-ceph-tools" --no-headers | head -n 1 | awk '{print $1}') bash -c 'ceph auth get-key client.admin' > ${TMP_DIR}/secret
oc create -n rook-ceph secret generic ceph-secret-admin --from-file=${TMP_DIR}/secret

git clone https://github.com/hongkailiu/external-storage.git  ${TMP_DIR}/openshift/external-storage
git -C ${TMP_DIR}/openshift/external-storage checkout master-on-ocp-4

### not sure why we need to switch the project
oc project rook-ceph
oc adm policy add-scc-to-user anyuid -n rook-ceph -z cephfs-provisioner

oc create -f ${TMP_DIR}/openshift/external-storage/ceph/cephfs/deploy/rbac
oc get pod -l app=cephfs-provisioner  -n rook-ceph

readonly MONITOR=$(oc get svc -l app=rook-ceph-mon -n rook-ceph --no-headers | head -n 1 | awk '{print $3}')

cat ${TMP_DIR}/openshift/external-storage/ceph/cephfs/example/class.yaml | sed -e "s/172.30.35.119/${MONITOR}/g" > ${TMP_DIR}/class.yaml

oc create -f ${TMP_DIR}/class.yaml

# oc create -f ${TMP_DIR}/openshift/external-storage/ceph/cephfs/example/claim.yaml -n rook-ceph
# oc get pvc -n rook-ceph

oc create -f ${TMP_DIR}/rook/cluster/examples/kubernetes/ceph/storageclass.yaml
# oc get sc rook-ceph-block

# oc new-project ttt
# oc process -f https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/pvc_template.yaml -p PVC_NAME=claim1 -p STORAGE_CLASS_NAME=rook-ceph-block | oc create -f -
