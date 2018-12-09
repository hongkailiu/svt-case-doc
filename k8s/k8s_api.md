# [Access Clusters Using the Kubernetes API](https://kubernetes.io/docs/tasks/administer-cluster/access-cluster-api/)

## [Accessing the API from a Pod](https://kubernetes.io/docs/tasks/administer-cluster/access-cluster-api/#accessing-the-api-from-a-pod)

```bash
# oc new-project ttt
# oc create -f https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/pod_test.yaml

# oc get pod web -o json | jq .spec.volumes
[
  {
    "name": "default-token-kz2r2",
    "secret": {
      "defaultMode": 420,
      "secretName": "default-token-kz2r2"
    }
  }
]


$ oc get sa default -o yaml
apiVersion: v1
imagePullSecrets:
- name: default-dockercfg-75gjq
kind: ServiceAccount
metadata:
  creationTimestamp: 2018-12-09T04:11:33Z
  name: default
  namespace: myproject
  resourceVersion: "2136"
  selfLink: /api/v1/namespaces/myproject/serviceaccounts/default
  uid: 83b09bd3-fb68-11e8-9ba1-525400e74360
secrets:
- name: default-token-kz2r2
- name: default-dockercfg-75gjq

# oc get secret default-token-kz2r2
NAME                  TYPE                                  DATA      AGE
default-token-kz2r2   kubernetes.io/service-account-token   4         6m

```

Note that the secret volume is injected automatically:
1. by who? OCP or K8S?
2. What is it for? 

