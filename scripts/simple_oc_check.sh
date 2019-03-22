#!/bin/bash

### create the bc used in the test
# $ oc new-project testproject
### Create an app
# $ oc new-app https://github.com/sclorg/cakephp-ex

### download and start the script
### curl -O https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/scripts/simple_oc_check.sh
### $ bash -x ./simple_oc_check.sh 2>&1 | tee -a test.log

#set -o errexit
set -o nounset
set -o pipefail

while true
do
  echo "===$(date --iso-8601=seconds)==="
  oc get pod -n testproject
  oc get bc --all-namespaces
  oc start-build -n testproject cakephp-ex
  sleep 6
done
