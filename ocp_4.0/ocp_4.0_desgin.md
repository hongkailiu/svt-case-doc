# OCP 4: doc list

Thanks to Jiri and Siva Reddy

## gdoc (rh internal)

* [OpenShift 4 Terminology](https://docs.google.com/document/d/1bRuZcLzgK3w-nVABu3ylu_37XTtsG-255hFJ7Zh8-lI/edit)
* [OpenShift 4 Goals](https://docs.google.com/document/d/16JwTljY3lD3J7j-BHJByu117dRyCx03hY5exPfKMKJE/edit?ts=5b98e90d#)
* [OpenShift 4 Automated Testing](https://docs.google.com/document/d/1sn_r8QwchNLnOJRpg4M4shWzYSQ3Aif2KEIXl37JP6Q/edit)
    * How to add an e2e operator CI job to your operator repo
* [OpenShift 4 CI and Release Flow
](https://docs.google.com/document/d/1PAHSF86Un6CdG7STX-vIGbrgjVTnVpDOSBplos0U8Rk/edit?ts=5ba3d3e3)
* [OpenShift 4 - Core Update Design](https://docs.google.com/document/d/1SoIcId9VjbgXtOJ1PK1qP6uz79Qyf0AgobubnxAo9M8)
* [Content distribution and OTA in converged platform](https://docs.google.com/document/d/19nqtRuyEf1qxqxlcINkp6RNNdXjg4gX6xaGX5cUfEdM/edit)
* [ClusterOperator Versioning](https://docs.google.com/document/d/1YV_rJ6qR46_DV1s6RwobTYHX0CCE4CIBnt_VRPtN8Nw/edit#heading=h.j35cxjc8vibg)
* [OpenShift 4 Release Image and Release Payload](https://docs.google.com/document/d/1CGZVEyuloZ9oD4NUArW6dnEpi0WFc6BP2tqPSwFZTCY/edit#heading=h.1zgrwxmpgxbr)
    * How do we test an operator as part of an install in a PR CI job?
    * How do I try out the release process for local iteration?
* [Cincinnati in OpenShift](https://docs.google.com/document/d/1TMV_1qNMmobhFfV0iVY67Bv9c-9woUWtxDRk4vb5m-U/edit#heading=h.du4f4lkqahc8)
* [How to upgrade the cluster through CVO](How to upgrade the cluster through CVO)

## Terminology

* Update/Release Payload: The information the cluster update operator needs to update itself and the other components.  Typically this is a versioned set of manifests that reference Kubernetes deployments containing known image version numbers.

    ```
    ### to show all the images in a release
    $ oc adm release info --pullspecs registry.svc.ci.openshift.org/ocp/release:4.0.0-0.nightly-2019-02-20-194410
    ```


* Cluster Version Operator (CVO): 

    * [The Cluster Version Operator](https://github.com/openshift/cluster-version-operator/), an instance of which runs in every cluster, is in charge of performing updates to the cluster.

    ```
    $ oc get pod -n openshift-cluster-version
    NAME                                        READY   STATUS    RESTARTS   AGE
    cluster-version-operator-6fdf976c58-b2h7s   1/1     Running   0          38m
    $ oc get clusterversion version 
    NAME      VERSION                             AVAILABLE   PROGRESSING   SINCE   STATUS
    version   4.0.0-0.nightly-2019-02-24-045124   True        False         14m     Cluster version is 4.0.0-0.nightly-2019-02-24-045124

    ```

    * The operator that downloads and keeps all components on the cluster up to date (sets the cluster to a specific version). It delegates most details to second level operators (one for Kubernetes control plane, one for networking, etc) in order to reduce the amount of possible failures.

    ```
    # oc adm upgrade -h

    ```

## samples-operator

* [cluster-samples-operator](https://github.com/openshift/cluster-samples-operator)
* [https://github.com/operator-framework/operator-sdk-samples](https://github.com/operator-framework/operator-sdk-samples)


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
$ ll $BUNDLE_DIR
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

$ operator-courier push $BUNDLE_DIR $EXAMPLE_NAMESPACE $EXAMPLE_REPOSITORY $EXAMPLE_RELEASE $AUTH_TOKEN

```

Blocked by [operator-sdk-samples/issues/57](https://github.com/operator-framework/operator-sdk-samples/issues/57).