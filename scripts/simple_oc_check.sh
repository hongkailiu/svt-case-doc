#!/bin/bash

### $ bash -x ./test.sh 2>&1 | tee -a test.log

set -o errexit
set -o nounset
set -o pipefail

while true
do
	echo "===$(date --iso-8601=seconds)==="
  oc get pod -n testproject
  oc get bc --all-namespaces
  oc start-build -n testproject cakephp-ex
	sleep 10
done
