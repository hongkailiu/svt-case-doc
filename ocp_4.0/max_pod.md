# Max pods

The default value for maxPods on all the nodes is 250 pods.  In order to change it, you'll need to first create a KubeletConfig CR (Custom Resource) and then apply it.

Additional documentation can be found in this [demo](https://drive.google.com/file/d/1Fg92EKqBpKBhjuN-tV3BcdE3FWU3w3sP/view)

Create the following CR with the desired value for maxPods, and label for the mahcineConfigPool selector, set to "custom-kubelet: large-pods"

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

```
$ oc edit machineconfigpool worker:
```

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
...

```
Save the edited worker machineconfigpool.

Apply the KubeletConfig CR to force the change to the maxPods value on all the worker nodes:

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

Also as a result of applyin the kubeltconfig CR, a new managed worker machineconfig "99-worker-<....>-kubelet" is created:

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