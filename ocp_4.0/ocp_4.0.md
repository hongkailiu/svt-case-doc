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

### pick up the right build

#### aos puddles
Starting from a particular puddles, we can get the puddle number: eg, you are interested in [puddle v4.0.0-0.131.0_2019-01-10.1](http://download.eng.bos.redhat.com/rcm-guest/puddles/RHAOS/AtomicOpenShift/4.0/v4.0.0-0.131.0_2019-01-10.1/).

Then we need to find out the installer binary for that puddle which is in a docker image: 

Method 1: docker

Set up docker config:

```
$ cat ~/.docker/config.json 
{
	"auths": {
		"registry.svc.ci.openshift.org": {
			"auth": "<registry.svc.ci.openshift.org_token>"
		},
    "quay.io": {
            "auth": "<https://try.openshift.com/_pull_secret>"
    }
	}
}

```

```
$ export ID=$(docker create quay.io/openshift-release-dev/ocp-v4.0-art-dev:v4.0.0-0.131.0.0-ose-installer)
$ docker cp $ID:/usr/bin/openshift-install .
$ docker rm $ID
```

Method 2: skopeo

```
$ export quay_secret="<https://try.openshift.com/_pull_secret>"
$ export quay_creds=$(echo ${quay_secret} | base64 --decode)
###if you want to do a inspect
$ skopeo inspect docker://quay.io/openshift-release-dev/ocp-v4.0-art-dev:v4.0.0-0.131.0.0-ose-installer --creds ${quay_creds} | jq -r .RepoTags[] | grep "ose-installer"

### ref: https://github.com/containers/libpod/blob/master/docs/podman-cp.1.md
### NOTE we have to use root for this
$ sudo -i
# export quay_secret="<https://try.openshift.com/_pull_secret>"
# export quay_creds=$(echo ${quay_secret} | base64 --decode)
# podman pull quay.io/openshift-release-dev/ocp-v4.0-art-dev:v4.0.0-0.131.0.0-ose-installer --creds ${quay_creds}
# export ID=$(podman create quay.io/openshift-release-dev/ocp-v4.0-art-dev:v4.0.0-0.131.0.0-ose-installer)
# mnt=$(podman mount ${ID})
# cp ${mnt}/bin/openshift-install .
# podman umount ${ID}
# podman rm ${ID}
# ./openshift-install version
./openshift-install v4.0.0-0.131.0.0-dirty

### how come it's dirty?
### https://mojo.redhat.com/groups/atomicopenshift/blog/2019/01/11/ocp-40-high-touch-beta-htb-notes-from-art

```

Then choose a night build from [Images: Release Status: 4.0.0-0.nightly](https://openshift-release.svc.ci.openshift.org/) and set up `OPENSHIFT_INSTALL_RELEASE_IMAGE_OVERRIDE`, eg,

```
$ export OPENSHIFT_INSTALL_RELEASE_IMAGE_OVERRIDE=registry.svc.ci.openshift.org/ocp/release:4.0.0-0.nightly-2019-01-11-155526
$ openshift-install create cluster --dir=./20190111
### make sure the pull secret contains auth for registry.svc.ci.openshift.org

```

Note that the mapping between puddle and nightly build is still unclear to me (See the update on 20190115 below).

However, Tim Tielawa suggested we should use installer from registry.svc.ci.openshift.org/ocp, eg, `registry.svc.ci.openshift.org/ocp/4.0-art-latest-2019-01-11-000044:installer`. 

This way the matching of installer and images are ensured but we do not know which puddle we are testing.

A more convienent way to get installer image id for exacting installer:

```
$ oc adm release info --pullspecs registry.svc.ci.openshift.org/ocp/release:4.0.0-0.nightly-2019-01-11-205323 | grep installer
  installer                                     registry.svc.ci.openshift.org/ocp/4.0-art-latest-2019-01-11-205323@sha256:58b5bc0f10caa359d520b7ee2cf695b60c1971d3c141abe99d33b8e024ef114f
$ export ID=$(docker create registry.svc.ci.openshift.org/ocp/4.0-art-latest-2019-01-11-205323@sha256:58b5bc0f10caa359d520b7ee2cf695b60c1971d3c141abe99d33b8e024ef114f)
...
```

After the cluster is created, we can `rpm-ostree status` on one of the nodes
to check rhcos verison. It should matching one in [Red Hat CoreOS release](https://releases-redhat-coreos.cloud.paas.upshift.redhat.com/).

#### Update on 20190115:

When art-nightly builds are pushed to quay.io registry (notified by Xiaoli's email for the monent. A more automated procedure would be nice), we could use the
following steps to consume the builds:

1.  Extracted installer from latest build (quay.io image)
2. `export OPENSHIFT_INSTALL_OS_IMAGE_OVERRIDE=ami-<hash>`
3. Run the installer - should not need the oc login/docker login/build override or extra pull secrets

In Xiaoli's email, this information showed up:

```
1. 4.0-art-latest-2019-01-15-010905 mirrored to quay.io: quay.io/openshift-release-dev/ocp-release:4.0.0-0.1
2. RHCOS Build 47.249 is our latest RHCOS beta candidate build
```

Item 1 indicates we should use the installer binary in `quay.io/openshift-release-dev/ocp-release:4.0.0-0.1`.

Item 2 indicates to get the AMI id from [Red Hat CoreOS release](https://releases-redhat-coreos.cloud.paas.upshift.redhat.com/) by:

* RHCOS Build 47.249
* region: in our case: `us-east-2	ami-085b89e82b74a76b5`

#### Update on 20190122

Clayton Coleman's email `As of 4.0, all OKD images are being pushed to`: `quay.io/openshift/origin-COMPONENT:v4.0`. Eg,

```
$ skopeo inspect docker://quay.io/openshift/origin-pod:v4.0 --creds ${quay_creds}
```

See [the component list](https://github.com/openshift/origin/blob/0a62a17d585336f8c977939baba39843e484c395/hack/lib/constants.sh#L302-L319) from Maciej Szulik's email.

Qs: 

* what is the relationship among those repos?

    * [registry.svc.ci.openshift.org/openshift/origin-release:v4.0](https://github.com/openshift/installer/blob/master/pkg/asset/ignition/bootstrap/bootstrap.go#L39)
    * registry.svc.ci.openshift.org/ocp/release:4.0.0-0.nightly-2019-01-11-155526
    * quay.io/openshift-release-dev/ocp-v4.0-art-dev:v4.0.0-0.131.0.0-ose-installer

* if the default one is `registry.svc.ci.openshift.org/openshift/origin-release:v4.0`

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
### Updating kubeltArgument "maxPods"
The default value for maxPods on all the nodes is 250 pods.  In order to change it, you'll need to first create a KubeletConfig CRD and then apply it.

Additional documentation can be found in this [demo](https://drive.google.com/file/d/1Fg92EKqBpKBhjuN-tV3BcdE3FWU3w3sP/view)

Create the following CRD with the desired value for maxPods, and label for the mahcineConfigPool selector, set to "custom-kubelet: large-pods"

worker-kube-config-change-maxPods-crd.yaml:
```
apiVersion: machineconfiguration.openshift.io/v1
kind: KubeletConfig
metadata:
  name: set-max-pods
spec:
  machineConfigPoolSelector:
    matchLabels:
      custom-kubelet: large-pods
  kubeletConfig:
    maxPods: 500
```

Next, add the matching label "custom-kubelet: large-pods" in the metadata section under "labels:", in the worker machineConfigPool:

$ oc edit machineconfigpool worker:
add:
```
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfigPool
metadata:
  creationTimestamp: 2019-01-31T17:02:34Z
  generation: 1
  labels:
    custom-kubelet: large-pods
  name: worker
.
.
.

```
Save the edited worker machineconfigpool.

Apply the KubeletConfig CRD to force the change to the maxPods value on all the worker nodes:

```
$ oc create -f worker-kube-config-change-maxPods-crd.yaml
```

Now you'll see each worker node become ScheduleDisabled as it is rebooted to apply the new value for the kubletArgument.
Once the worker node is Ready again, it becomes schedualable.

After all the worker nodes get rebooted and become ready and schedulable again, you can check the new value for maxPods
with:
  oc describe node <worker-node-hostname>
	
```
Allocatable:
 attachable-volumes-aws-ebs:  39
 cpu:                         3500m
 hugepages-1Gi:               0
 hugepages-2Mi:               0
 memory:                      15815652Ki
 pods:                        500     <=== new value
```
	
or check it in the worker node /etc/kubernetes/kublet.conf file

```
kubelet.conf
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous: {}
  webhook:
    cacheTTL: 0s
  x509: {}
authorization:
  webhook:
    cacheAuthorizedTTL: 0s
    cacheUnauthorizedTTL: 0s
cgroupDriver: systemd
clusterDNS:
- 172.30.0.10
clusterDomain: cluster.local
cpuManagerReconcilePeriod: 0s
evictionPressureTransitionPeriod: 0s
featureGates:
  RotateKubeletServerCertificate: true
fileCheckFrequency: 0s
httpCheckFrequency: 0s
imageMinimumGCAge: 0s
kind: KubeletConfiguration
maxPods: 500
nodeStatusUpdateFrequency: 0s
rotateCertificates: true
runtimeRequestTimeout: 10m0s
serializeImagePulls: false
serverTLSBootstrap: true
staticPodPath: /etc/kubernetes/manifests
streamingConnectionIdleTimeout: 0s
syncFrequency: 0s
systemReserved:
  cpu: 500m
  memory: 500Mi
```

Also as a result of applyin the kubeltconfig CRD, a new managed worker machineconfig "99-worker-<....>-kubelet" is created:

```
# oc get machineconfig
NAME                                                     GENERATEDBYCONTROLLER   IGNITIONVERSION   CREATED   OSIMAGEURL
00-master                                                4.0.0-0.150.0.0-dirty   2.2.0             21h       
00-master-ssh                                            4.0.0-0.150.0.0-dirty                     21h       
00-worker                                                4.0.0-0.150.0.0-dirty   2.2.0             21h       
00-worker-ssh                                            4.0.0-0.150.0.0-dirty                     21h       
01-master-kubelet                                        4.0.0-0.150.0.0-dirty   2.2.0             21h       
01-worker-kubelet                                        4.0.0-0.150.0.0-dirty   2.2.0             21h       
99-worker-01517e1f-257a-11e9-b836-0a1d5349802c-kubelet   4.0.0-0.150.0.0-dirty                     18h       
master-3b33a624e8cdc34edc304df8b718b75c                  4.0.0-0.150.0.0-dirty   2.2.0             21h       
worker-622a5715a8cc9d1f957d28c420a2d796                  4.0.0-0.150.0.0-dirty   2.2.0             21h       
worker-833572c9ab865fa5f0f36ccdb21a5648                  4.0.0-0.150.0.0-dirty   2.2.0             18h       
root@ip-172-31-47-83: ~ # 
```


### network cdr

* Mike Fiedler [9:57 AM]
    1) openshift-install create installconfig
    2) edit the yaml
    3) openshift-install create manifests
    4) openshift-install create cluster

### Default build configuration

https://groups.google.com/forum/#!topic/openshift-4-dev-preview/VkTG-f5CyG8

It seems that by default, the build pods run only on workers:

```
$ oc get node | grep worker
ip-10-0-143-241.us-east-2.compute.internal   Ready     worker    1h        v1.11.0+c69f926354
ip-10-0-144-88.us-east-2.compute.internal    Ready     worker    1h        v1.11.0+c69f926354
ip-10-0-160-168.us-east-2.compute.internal   Ready     worker    1h        v1.11.0+c69f926354

$ oc get pod --all-namespaces -o wide | grep "\-build" | awk '{print $8}' | sort -u
ip-10-0-143-241.us-east-2.compute.internal
ip-10-0-144-88.us-east-2.compute.internal
ip-10-0-160-168.us-east-2.compute.internal

$ oc get pod --all-namespaces -o wide | grep "\-build" | awk '{print $8}' | wc -l
50

```

### AllowAll IDP for oauthconfig

[mojo.page](https://mojo.redhat.com/docs/DOC-1186975) and [discussion@mailing-list](http://post-office.corp.redhat.com/archives/aos-qe/2019-January/msg00110.html)



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


