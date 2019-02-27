# OCP 4: operator framework

This page documents the revisit on OCP 4.0 of operator framework after [operator_framework.md](../learn/operator_framework.md).

## Make you own operator

svt-app-operator:

```
### https://github.com/operator-framework/operator-sdk/blob/master/doc/user-guide.md#2-run-locally-outside-the-cluster
### debugging operator locallay
# operator-sdk --version
operator-sdk version v0.5.0+git

# kubectl create -f deploy/crds/app_v1alpha1_svt_crd.yaml 
$ kubectl create -f deploy/service_account.yaml
$ kubectl create -f deploy/role.yaml
$ kubectl create -f deploy/role_binding.yaml

# cd ~/go/src/github.com/hongkailiu/operators/svt-app-operator
# oc project abc
# export OPERATOR_NAME=svt-app-operator
# operator-sdk up local --namespace=abc

### in another terminal
# oc create -f deploy/crds/app_v1alpha1_svt_cr.yaml 
# oc get deploy 
NAME   READY   UP-TO-DATE   AVAILABLE   AGE
svt    3/3     3            3           66s

# oc get svc
NAME   TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
svt    ClusterIP   172.30.230.3   <none>        8080/TCP   70s

# oc get svt
NAME   AGE
svt    2m1s
# oc get svt svt -o yaml
apiVersion: app.test.com/v1alpha1
kind: SVT
...
spec:
  size: 3
status:
  nodes:
  - svt-5ccf466b8c-f562w
  - svt-5ccf466b8c-khkjc
  - svt-5ccf466b8c-mrs4r

### access the svc out of the cluster network via route
# oc expose svc svt
+route.route.openshift.io/svt exposed
# oc get route
NAME   HOST/PORT                                            PATH   SERVICES   PORT   TERMINATION   WILDCARD
svt    svt-abc.apps.hongkliu1.qe.devcluster.openshift.com          svt        8080                 None
# curl svt-abc.apps.hongkliu1.qe.devcluster.openshift.com
{"version":"2.0.0","ips":["127.0.0.1","::1","10.128.2.51","fe80::60de:f7ff:fe55:35cd"],"now":"2019-02-26T18:01:28.955432726Z"}

# oc get svt svt -o yaml
apiVersion: app.test.com/v1alpha1
kind: SVT
...
spec:
  size: 2
status:
  nodes:
  - svt-5ccf466b8c-f562w
  - svt-5ccf466b8c-khkjc



```

Build image when all manual tests pass:

```
# operator-sdk build docker.io/hongkailiu/svt-app-operator:a012
# docker login docker.io
# docker push docker.io/hongkailiu/svt-app-operator:a012

```

Test with operator deployment:

```
# oc create -f ./deploy/operator.yaml
# oc get deploy
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
svt-app-operator   1/1     1            1           32s
# oc get pod
NAME                                READY   STATUS    RESTARTS   AGE
svt-app-operator-59cf6f6f8d-q8gr6   1/1     Running   0          3m45s
# oc logs svt-app-operator-59cf6f6f8d-q8gr6 -f

### in another terminal ... start to test ...
# oc create -f ./deploy/crds/app_v1alpha1_svt_cr.yaml
...

```

## operator-hub

[community-operators](https://github.com/operator-framework/community-operators)

Add our operator `svt-app-operator` into the community:

Before commit to the repo, [test first](https://github.com/operator-framework/community-operators/blob/master/docs/testing-operators.md):

```
###https://github.com/operator-framework/operator-lifecycle-manager/blob/master/pkg/api/apis/operators/v1alpha1/clusterserviceversion_types.go
$ source p3env/bin/activate
$ pip3 install operator-courier
$ BUNDLE_DIR=${GOPATH}/src/github.com/hongkailiu/operators/svt-app-operator/deploy/BUNDLE_DIR
$ ll "$BUNDLE_DIR"
total 24
-rw-rw-r--. 1 hongkliu hongkliu   629 Feb 25 14:35 svt-app-operator.crd.yaml
-rw-rw-r--. 1 hongkliu hongkliu    95 Feb 26 01:17 svt-app-operator.package.yaml
-rw-rw-r--. 1 hongkliu hongkliu 15386 Feb 25 23:53 svt-app-operator.v0.0.2.clusterserviceversion.yaml

$ operator-courier verify $BUNDLE_DIR

$ AUTH_TOKEN=$(curl -sH "Content-Type: application/json" -XPOST https://quay.io/cnr/api/v1/users/login -d '
{
    "user": {
        "username": "'"${QUAY_USERNAME}"'",
        "password": "'"${QUAY_PASSWORD}"'"
    }
}' | jq -r '.token')


EXAMPLE_NAMESPACE=hongkailiu
EXAMPLE_REPOSITORY=svt-app-operator
EXAMPLE_RELEASE=0.0.2

$ operator-courier push "$BUNDLE_DIR" "$EXAMPLE_NAMESPACE" "$EXAMPLE_REPOSITORY" "$EXAMPLE_RELEASE" "$AUTH_TOKEN"

```

Blocked by [operator-sdk-samples/issues/57](https://github.com/operator-framework/operator-sdk-samples/issues/57). 

20190227: Unblocked now.

```
$ cd ${GOPATH}/src/github.com/hongkailiu/operators/svt-app-operator
$ oc project openshift-marketplace
$ oc get OperatorSource
NAME                  TYPE          ENDPOINT              REGISTRY              DISPLAYNAME           PUBLISHER   STATUS      MESSAGE                                       AGE
certified-operators   appregistry   https://quay.io/cnr   certified-operators   Certified Operators   Red Hat     Succeeded   The object has been successfully reconciled   172m
community-operators   appregistry   https://quay.io/cnr   community-operators   Community Operators   Red Hat     Succeeded   The object has been successfully reconciled   172m
redhat-operators      appregistry   https://quay.io/cnr   redhat-operators      Red Hat Operators     Red Hat     Succeeded   The object has been successfully reconciled   172m

$ oc create -f deploy/test/community.operatorsource.cr.yaml 
operatorsource.marketplace.redhat.com/my-operators created

$ oc get OperatorSource my-operators
NAME           TYPE          ENDPOINT              REGISTRY     DISPLAYNAME           PUBLISHER   STATUS      MESSAGE                                       AGE
my-operators   appregistry   https://quay.io/cnr   hongkailiu   Community Operators   Red Hat     Succeeded   The object has been successfully reconciled   55s

```

After some minutes, refresh console UI. Operator `svt-app-operator` shows up:

![](../images/svt-app-operator.png)

We can also check by

```
$ kubectl get opsrc my-operators -o=custom-columns=NAME:.metadata.name,PACKAGES:.status.packages -n openshift-marketplace
NAME           PACKAGES
my-operators   svt-app-operator

###Note that CatalogSourceConfig is created already automatically
# oc get CatalogSourceConfig my-operators
NAME           TARGETNAMESPACE         PACKAGES           STATUS      DISPLAYNAME           PUBLISHER   MESSAGE                                       AGE
my-operators   openshift-marketplace   svt-app-operator   Succeeded   Community Operators   Red Hat     The object has been successfully reconciled   115m

### this pod will download the release info from app registry
# oc get pod my-operators-849b77b965-jxblq
NAME                            READY   STATUS    RESTARTS   AGE
my-operators-849b77b965-jxblq   1/1     Running   0          2m31s

# oc logs my-operators-849b77b965-jxblq | grep download
time="2019-02-27T17:33:45Z" level=info msg="downloading repository: hongkailiu/svt-app-operator:0.0.2 from https://quay.io/cnr" port=50051 type=appregistry
time="2019-02-27T17:33:47Z" level=info msg="download complete - 1 repositories have been downloaded" port=50051 type=appregistry

```

Release a new version:

```
EXAMPLE_RELEASE=0.0.3
$ operator-courier push "$BUNDLE_DIR" "$EXAMPLE_NAMESPACE" "$EXAMPLE_REPOSITORY" "$EXAMPLE_RELEASE" "$AUTH_TOKEN"

###if the new release is not picked up
$ oc delete pod my-operators-849b77b965-jxblq
###this will download the release again
```


We can install the operator on the UI. Or via oc cli:

```
$ ???

```

Blocked again:

Need to understand those first.

```
Alexander Greene [19 minutes ago]
The `installModes` behave somewhat differently than you've described.  
When deploying your operator to a namespace OLM will look for an `OperatorGroup` in the namespace and see which `installMode` it matches. 
If the `installMode` is supported by your operator, OLM  will add an annotation to your csv with a string that lists which namespaces 
to watch seperated by commas. Your operator should look for this annotation and assign it to an environment variable. 
The operator then needs to be configured to watch those namespaces for CRs. (edited)


Alexander Greene [15 minutes ago]
OLM will deploy the operator if the `installMode` type of the `operatorGroup` in the `namespace`  is supported. 
The `installMode` type is identified by OLM based on the `targetNamespaces` field in the `operatorGroup` resource

https://docs.google.com/document/d/10SJ_k7efVMnNxv49AT-jTdvnKF_O0R1CFdT_-KOW1Qg/edit#heading=h.efjm54igbbni


Alec Merdler
https://github.com/operator-framework/operator-lifecycle-manager/pull/721


Kevin Rizza   [42 minutes ago]
@hongkliu the operator source creates a source from which data is obtained from quay. the subscription creation workflow is what adds the csv to the namespace
```