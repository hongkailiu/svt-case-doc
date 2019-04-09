#!/bin/bash

### https://bugzilla.redhat.com/show_bug.cgi?id=1689061
# $ oc new-project testproject
### Create an app
# $ oc new-app https://github.com/sclorg/django-ex

### download and start the script
### curl -O https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/scripts/simple_1689061.sh
### $ bash -x ./simple_1689061.sh 2>&1 | tee -a test.log

set -o errexit
set -o nounset
set -o pipefail

echo "===$(date --iso-8601=seconds)==="

running_build_node=ip-10-0-141-143.us-east-2.compute.internal
standby_build_node=ip-10-0-149-124.us-east-2.compute.internal

oc adm cordon ${standby_build_node}
oc start-build -n testproject django-ex
oc get pod -o wide -n testproject
oc get build -n testproject
oc adm uncordon ${standby_build_node}
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -n core@${running_build_node} "sudo dd if=/dev/urandom of=file$(date +"%s").txt bs=1048576 count=1024"
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -n core@${running_build_node} "sudo df -h"
oc get pod -o wide -n testproject
oc get build -n testproject

