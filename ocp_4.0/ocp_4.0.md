# OCP 4.0

## Doc 

* mojo pages (RH internal):
  * [OCP 4.0 AWS Architecture](https://mojo.redhat.com/docs/DOC-1188781)
  * [OpenShift 4.0 Technical Enablement](https://mojo.redhat.com/docs/DOC-1187782)
    * [OCP 4.0 Technical Enablement 1 (Beta)](https://mojo.redhat.com/events/4974)
    * [OCP 4.0 Technical Enablement 2 (Beta)](https://mojo.redhat.com/events/4975)
    * [OCP 4.0 Technical Enablement 3 (Beta)](https://mojo.redhat.com/events/4976)

* [openshift/training](https://github.com/openshift/training)

## Build

* [Red Hat CoreOS release](https://releases-redhat-coreos.cloud.paas.upshift.redhat.com/)
* [aos-puddles: 4.0](http://download.eng.bos.redhat.com/rcm-guest/puddles/RHAOS/AtomicOpenShift/4.0/)
* [Images: Release Status: 4.0.0-0.nightly](https://openshift-release.svc.ci.openshift.org/)

## Configuration

### default node selector

Get:

```
$ grep -irn "defaultNodeSelector" /etc/

```

They are now defined by a configMap used by api-server, eg, `/etc/kubernetes/static-pod-resources/kube-apiserver-pod-1/configmaps/config/config.yaml` which has `"projectConfig":{"defaultNodeSelector":""},"...`.

Set: Unknow. [issues/1020](https://github.com/openshift/installer/issues/1020)

### KUBE_MAX_PD_VOLS for master controller

Get: Unknow.

Set: [issues/1021](https://github.com/openshift/installer/issues/1021)

```
   env:
   - name: KUBE_MAX_PD_VOLS
     value: "60" 
```

## Components: where are the <openshift|kube>-pods?

Master-<api|controller> seems split into 2 namespaces.

api-server:

```
$ oc get pod -n openshift-apiserver
NAME              READY     STATUS    RESTARTS   AGE
apiserver-67f62   1/1       Running   0          1d
apiserver-r25z2   1/1       Running   0          1d
apiserver-t6t6l   1/1       Running   0          1d

$ oc get pod -n openshift-kube-apiserver
NAME                                                                 READY     STATUS      RESTARTS   AGE
installer-1-ip-10-0-23-209.us-west-2.compute.internal                0/1       Completed   0          1d
installer-1-ip-10-0-4-152.us-west-2.compute.internal                 0/1       Completed   0          1d
installer-1-ip-10-0-47-153.us-west-2.compute.internal                0/1       Completed   0          1d
installer-2-ip-10-0-23-209.us-west-2.compute.internal                0/1       Completed   0          1d
installer-2-ip-10-0-4-152.us-west-2.compute.internal                 0/1       Completed   0          1d
installer-2-ip-10-0-47-153.us-west-2.compute.internal                0/1       Completed   0          1d
openshift-kube-apiserver-ip-10-0-23-209.us-west-2.compute.internal   1/1       Running     0          1d
openshift-kube-apiserver-ip-10-0-4-152.us-west-2.compute.internal    1/1       Running     0          1d
openshift-kube-apiserver-ip-10-0-47-153.us-west-2.compute.internal   1/1       Running     0          1d


```

master-controller:

```
$ oc get pod -n openshift-controller-manager
NAME                       READY     STATUS    RESTARTS   AGE
controller-manager-r6dbb   1/1       Running   0          1d
controller-manager-s57hl   1/1       Running   0          1d
controller-manager-vbqpb   1/1       Running   0          1d

$ oc get pod -n openshift-kube-controller-manager
NAME                                                                          READY     STATUS      RESTARTS   AGE
installer-1-ip-10-0-23-209.us-west-2.compute.internal                         0/1       Completed   0          1d
installer-1-ip-10-0-4-152.us-west-2.compute.internal                          0/1       Completed   0          1d
installer-1-ip-10-0-47-153.us-west-2.compute.internal                         0/1       Completed   0          1d
openshift-kube-controller-manager-ip-10-0-23-209.us-west-2.compute.internal   1/1       Running     0          1d
openshift-kube-controller-manager-ip-10-0-4-152.us-west-2.compute.internal    1/1       Running     0          1d
openshift-kube-controller-manager-ip-10-0-47-153.us-west-2.compute.internal   1/1       Running     0          1d


```

etcd:

```
$ oc get pod -n kube-system
NAME                                                    READY     STATUS    RESTARTS   AGE
etcd-member-ip-10-0-23-209.us-west-2.compute.internal   1/1       Running   0          1d
etcd-member-ip-10-0-4-152.us-west-2.compute.internal    1/1       Running   0          1d
etcd-member-ip-10-0-47-153.us-west-2.compute.internal   1/1       Running   0          1d

```

console:

```
$ oc get pod -n openshift-console
NAME                                READY     STATUS    RESTARTS   AGE
console-operator-648657b68b-86bgp   1/1       Running   0          15h
openshift-console-9b797745c-2qkqb   1/1       Running   0          1d
openshift-console-9b797745c-6fgwv   1/1       Running   0          1d
openshift-console-9b797745c-tlmqq   1/1       Running   0          1d

```

registry:

```
$ oc get pod -n openshift-image-registry
NAME                                              READY     STATUS    RESTARTS   AGE
cluster-image-registry-operator-88479ddf5-wjsvw   1/1       Running   0          1d
image-registry-69c9dbbc9c-kbbdl                   1/1       Running   0          1d
registry-ca-hostmapper-6lml6                      1/1       Running   0          1d
registry-ca-hostmapper-gmclg                      1/1       Running   0          1d
registry-ca-hostmapper-lt8fr                      1/1       Running   0          1d
registry-ca-hostmapper-qm5pd                      1/1       Running   0          1d
registry-ca-hostmapper-t6jnc                      1/1       Running   0          1d
registry-ca-hostmapper-zr266                      1/1       Running   0          1d

```

router:

```
$ oc get pod -n openshift-ingress
NAME                              READY     STATUS    RESTARTS   AGE
router-default-6d78c957d8-jkbgs   1/1       Running   0          1d

```

network:

```
$ oc get pod -n openshift-sdn
NAME                   READY     STATUS    RESTARTS   AGE
ovs-8xwrw              1/1       Running   0          1d
ovs-9tntc              1/1       Running   0          1d
ovs-fg2vs              1/1       Running   0          1d
ovs-n2ntq              1/1       Running   0          1d
ovs-ntf85              1/1       Running   0          1d
ovs-vgmwd              1/1       Running   0          1d
sdn-2bksd              1/1       Running   0          1d
sdn-2rsht              1/1       Running   0          1d
sdn-7njpx              1/1       Running   0          1d
sdn-controller-dz2xg   1/1       Running   1          1d
sdn-controller-hw4bp   1/1       Running   0          1d
sdn-controller-zcxqg   1/1       Running   0          1d
sdn-fwf5g              1/1       Running   0          1d
sdn-kbzg2              1/1       Running   0          1d
sdn-mftbb              1/1       Running   1          1d

```


