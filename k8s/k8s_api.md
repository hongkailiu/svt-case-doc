# [Access Clusters Using the Kubernetes API](https://kubernetes.io/docs/tasks/administer-cluster/access-cluster-api/)

## [Accessing the API from a Pod](https://kubernetes.io/docs/tasks/administer-cluster/access-cluster-api/#accessing-the-api-from-a-pod)

```bash
# oc new-project ttt
# oc create -f https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/pod_nginx_emptyDir.yaml

# oc get pod web -o json | jq .spec.volumes
[
  {
    "emptyDir": {},
    "name": "cache-volume"
  },
  {
    "name": "default-token-9w8qf",
    "secret": {
      "defaultMode": 420,
      "secretName": "default-token-9w8qf"
    }
  }
]

# oc get sa default -o yaml
apiVersion: v1
imagePullSecrets:
- name: default-dockercfg-f2hxx
kind: ServiceAccount
metadata:
  creationTimestamp: 2018-12-06T19:53:15Z
  name: default
  namespace: ttt
  resourceVersion: "47832"
  selfLink: /api/v1/namespaces/ttt/serviceaccounts/default
  uid: 91b9db86-f990-11e8-9c3c-02d258615392
secrets:
- name: default-token-9w8qf
- name: default-dockercfg-f2hxx

# oc get secret default-token-9w8qf 
NAME                  TYPE                                  DATA      AGE
default-token-9w8qf   kubernetes.io/service-account-token   4         6m

```

Note that the secret volume is injected automatically:
1. by who? OCP or K8S?
2. What is it for? 

