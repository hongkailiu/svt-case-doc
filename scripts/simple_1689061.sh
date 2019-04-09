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

running_build_node=
standby_build_node=

oc adm cordon ${standby_build_node}
oc start-build -n testproject django-ex
oc get pod -o wide -n testproject
oc get build -n testproject
oc adm uncordon ${standby_build_node}
oc debug node/${running_build_node} -- chroot /host df -h
oc debug node/${running_build_node} -- chroot /host dd if=/dev/urandom of=file.txt bs=1048576 count=300
oc debug node/${running_build_node} -- chroot /host df -h
oc get pod -o wide -n testproject
oc get build -n testproject

