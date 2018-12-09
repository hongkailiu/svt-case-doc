# [Access Clusters Using the Kubernetes API](https://kubernetes.io/docs/tasks/administer-cluster/access-cluster-api/)

## [Accessing the API from a Pod](https://kubernetes.io/docs/tasks/administer-cluster/access-cluster-api/#accessing-the-api-from-a-pod)

```bash
# oc new-project ttt
# oc create -f https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/pod_test.yaml

### pod has a secret `default-token-tvfv8` volume
# oc get pod web -o json | jq .spec.volumes
[
  {
    "name": "default-token-tvfv8",
    "secret": {
      "defaultMode": 420,
      "secretName": "default-token-tvfv8"
    }
  }
]

# oc get pod web -o json | jq .spec.containers[].volumeMounts[]
{
  "mountPath": "/var/run/secrets/kubernetes.io/serviceaccount",
  "name": "default-token-tvfv8",
  "readOnly": true
}


### this secret does exists in the namespace
# oc get secret default-token-tvfv8 -n ttt
NAME                  TYPE                                  DATA      AGE
default-token-tvfv8   kubernetes.io/service-account-token   4         6m

```

Note that the secret volume is injected automatically (Thanks to Mike):
1. by who? OCP or K8S? K8S
2. What is it for? Contacting k8s API server if necessary

More details:

* [When you create a pod, if you do not specify a service account, it is automatically assigned the default service account in the same namespace.](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#use-the-default-service-account-to-access-the-api-server)
```bash
# oc get pod web -o json | jq -r .spec.serviceAccountName
default

```

* `sa.secrets` defines [the list of secrets allowed to be used by pods running using](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#serviceaccount-v1-core).

```bash
# oc get sa default -o json | jq -r .secrets[].name
default-token-tvfv8
default-dockercfg-4gfnh

```

* [You can access the API from inside a pod using automatically mounted service account credentials](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/).
    [Pods can use the `kubernetes.default.svc` hostname to query the API server. ](https://kubernetes.io/docs/tasks/administer-cluster/access-cluster-api/#accessing-the-api-from-a-pod)

```bash
# oc get secret default-token-tvfv8 -n ttt -o json | jq -r '.data | keys[]'
ca.crt
namespace
service-ca.crt
token

### those data are all accessible in the pod
# oc rsh web 
sh-4.2# ls /var/run/secrets/kubernetes.io/serviceaccount
ca.crt	namespace  service-ca.crt  token

```

If we do not want to auto-mount the secret data, configure `pod.spec.automountServiceAccountToken` in [the pod definition](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#pod-v1-core).

Notice that we have [the meaning of those files](https://kubernetes.io/docs/tasks/administer-cluster/access-cluster-api/#accessing-the-api-from-a-pod) except `service-ca.crt`.

TODO: Try the example in the above page to use k8s API in a pod.