# certificate

* k8s components
    * [kube-apiserver](https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/)
    * [kube-controller-manager](https://kubernetes.io/docs/reference/command-line-tools-reference/kube-controller-manager/)
    * [kube-proxy](https://kubernetes.io/docs/reference/command-line-tools-reference/kube-proxy/)
    * [kube-scheduler](https://kubernetes.io/docs/reference/command-line-tools-reference/kube-scheduler/)
    * [kubelet](https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet/)
    * [access-kubernetes-api/configure-aggregation-layer](https://kubernetes.io/docs/tasks/access-kubernetes-api/configure-aggregation-layer/)

* k8s

    * [certificates](https://kubernetes.io/docs/concepts/cluster-administration/certificates/) and [PKI Certificates and Requirements](https://kubernetes.io/docs/setup/certificates/)
    * [kubelet-tls-bootstrapping](https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet-tls-bootstrapping/)
    * [certificate-rotation](https://kubernetes.io/docs/tasks/tls/certificate-rotation/)

* oc

    * [certificate_customization](https://docs.openshift.com/container-platform/3.11/install_config/certificate_customization.html)
    * [redeploying_certificates](https://docs.openshift.com/container-platform/3.11/install_config/redeploying_certificates.html)

We can use [k8s-playground@katacoda](https://www.katacoda.com/courses/kubernetes/playground) to check things out.


[setup/certificates](https://kubernetes.io/docs/setup/certificates/), [the-necessary-certificates](https://github.com/kubernetes/kubeadm/blob/master/docs/design/design_v1.7.md#phase-1-generate-the-necessary-certificates), and [Service Account key](https://nixaid.com/deploying-kubernetes-cluster-from-scratch/).

```
master $ kubectl get node
NAME      STATUS    ROLES     AGE       VERSION
master    Ready     master    3m        v1.11.3
node01    Ready     <none>    3m        v1.11.3

master $ tree /etc/kubernetes/pki/
/etc/kubernetes/pki/
├── apiserver.crt
├── apiserver-etcd-client.crt
├── apiserver-etcd-client.key
├── apiserver.key
├── apiserver-kubelet-client.crt
├── apiserver-kubelet-client.key
├── ca.crt
├── ca.key
├── etcd
│   ├── ca.crt
│   ├── ca.key
│   ├── healthcheck-client.crt
│   ├── healthcheck-client.key
│   ├── peer.crt
│   ├── peer.key
│   ├── server.crt
│   └── server.key
├── front-proxy-ca.crt
├── front-proxy-ca.key
├── front-proxy-client.crt
├── front-proxy-client.key
├── sa.key
└── sa.pub

1 directory, 22 files

node01 $ tree /etc/kubernetes/pki/
/etc/kubernetes/pki/
└── ca.crt

0 directories, 1 file


```

[requesting-a-certificate](https://kubernetes.io/docs/tasks/tls/managing-tls-in-a-cluster/#requesting-a-certificate) for your own application.

Check `csr`:

```
$ kubectl get csr
NAME                                                   AGE       REQUESTOR                 CONDITION
csr-w9gnj                                              16m       system:node:master        Approved,Issued
node-csr-iRVgclnf4l9Qn8crorHqpR1RApVvgkTXPYw-9GbKtBM   16m       system:bootstrap:96771a   Approved,Issued
```

Some [checking on openshift](https://bugzilla.redhat.com/show_bug.cgi?id=1688820): bugs on certs can go nasty. ^_^

Continue with [../tools/openssl.md](../tools/openssl.md).
