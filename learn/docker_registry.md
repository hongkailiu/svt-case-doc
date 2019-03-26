# Docker Registry

## Doc

* [Deploying a Registry on Existing Clusters](https://docs.openshift.com/container-platform/3.5/install_config/registry/deploy_registry_existing_clusters.html)

## Use filesystem driver for docker-registry

### Check the current setting (Optional)

```sh
# oc exec docker-registry-5-3skdd -- cat /etc/registry/config.yml
```

Note that <code>storage.s3</code> section shows that it uses aws-s3 as storage.

### Create PVC for registry (assumes AWS dynamic provisioning)
Use [registry_pvc.yaml](../files/registry_pvc.yaml): 

```sh
# oc create -n default -f https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/registry_pvc.yaml
# oc get pvc -n default
# oc get pv
### (DEPRECATED: This command has been moved to "oc set volume") oc volume -n default deploymentconfigs/docker-registry --add --name=registry-storage -t pvc \
    --claim-name=registry --overwrite -m /registry
# oc set volume -n default deploymentconfigs/docker-registry --add --name=registry-storage -t pvc --claim-name=registry --overwrite -m /registry
```

### Configure docker-registry to use filesystem
Use [registry_secret.yaml](../files/registry_secret.yaml)

```sh
# curl -LO https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/registry_secret.yaml
### (Command "new" is deprecated, use oc create secret) oc secrets new dockerregistry registry_secret.yaml
# oc create secret generic dockerregistry --from-file=./registry_secret.yaml
### (DEPRECATED: This command has been moved to "oc set volume") oc volume -n default dc/docker-registry --add --name=dockersecrets -m /etc/registryconfig --type=secret --secret-name=dockerregistry
# oc set volume -n default dc/docker-registry --add --name=dockersecrets -m /etc/registryconfig --type=secret --secret-name=dockerregistry
### (DEPRECATED: This command has been moved to "oc set env") oc env -n default dc/docker-registry REGISTRY_CONFIGURATION_PATH=/etc/registryconfig/registry_secret.yaml
# oc set env -n default dc/docker-registry REGISTRY_CONFIGURATION_PATH=/etc/registryconfig/registry_secret.yaml
```

### Set filesystem threads limit (Optional)
[src](https://github.com/openshift/origin/blob/master/vendor/github.com/docker/distribution/registry/storage/driver/filesystem/driver.go#L24)

```sh
oc env dc/docker-registry REGISTRY_STORAGE_FILESYSTEM_MAXTHREADS=100
```
### Check if the volume is being used
After using docker registry, eg, deployment of pods, run

```sh
# oc exec -n default docker-registry-5-3skdd -- ls /registry                                          
docker

```


## [GlusterFS As docker registery storage](https://github.com/openshift/openshift-ansible/tree/master/playbooks/byo/openshift-glusterfs)

### BYO playbook

The inventory file _2.file_ includes

```sh
[OSEv3:vars]
openshift_hosted_registry_storage_kind=glusterfs
openshift_hosted_registry_replicas=1
glusterfs_devices=["/dev/xvdf"]
openshift_storage_glusterfs_wipe=true
openshift_storage_glusterfs_image=registry.access.redhat.com/rhgs3/rhgs-server-rhel7
openshift_storage_glusterfs_version=3.3.0-362
openshift_storage_glusterfs_heketi_image=registry.access.redhat.com/rhgs3/rhgs-volmanager-rhel7
openshift_storage_glusterfs_heketi_version=3.3.0-362
#openshift_hosted_registry_glusterfs_swap=true
openshift_hosted_registry_storage_glusterfs_swap=True
openshift_hosted_registry_storage_glusterfs_swapcopy=True
#openshift_hosted_registry_storage_volume_size=10Gi
...

[glusterfs]
ec2-54-218-71-228.us-west-2.compute.amazonaws.com openshift_public_hostname=ec2-54-218-71-228.us-west-2.compute.amazonaws.com openshift_node_labels="{'region': 'primary', 'zone': 'default'}"
ec2-54-201-153-48.us-west-2.compute.amazonaws.com openshift_public_hostname=ec2-54-201-153-48.us-west-2.compute.amazonaws.com openshift_node_labels="{'region': 'primary', 'zone': 'default'}"
ec2-34-209-48-74.us-west-2.compute.amazonaws.com openshift_public_hostname=ec2-34-209-48-74.us-west-2.compute.amazonaws.com openshift_node_labels="{'region': 'primary', 'zone': 'default'}"

...
```

After running the byo playbook:

```sh
$ oc volumes pod docker-registry-1-pth6g
pods/docker-registry-1-pth6g
  pvc/registry-claim (allocated 5GiB) as registry-storage
    mounted at /registry
  secret/registry-certificates as registry-certificates
    mounted at /etc/secrets
  secret/registry-token-4wmf6 as registry-token-4wmf6
    mounted at /var/run/secrets/kubernetes.io/serviceaccount

$ oc get pv
NAME              CAPACITY   ACCESSMODES   RECLAIMPOLICY   STATUS    CLAIM                    STORAGECLASS   REASON    AGE
registry-volume   5Gi        RWX           Retain          Bound     default/registry-claim                            33m

$ oc new-project 
$ oc new-project aaa
$ oc new-app --template=cakephp-mysql-example
$ oc exec -n default docker-registry-1-pth6g -- ls /registry
docker
```

The _STORAGECLASS_ field is empty for above PV/PVC used for docker registry storage. So it does not use dynamic provision of PVC. See [here](https://docs.openshift.com/container-platform/3.6/install_config/persistent_storage/persistent_storage_glusterfs.html#gfs-provisioning) for more information where it is explained it uses gluster_plugin instead.


### PVC Attachment as a volume
Or we can still use the trick above when we set glusterfs up already (creating PVC using glusterfs storage class):

```sh
$ oc create -f https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/registry_pvc_glusterfs.yaml -n default
```

## OCP 4.0

Image registry is installed by [openshift/cluster-image-registry-operator](https://github.com/openshift/cluster-image-registry-operator).

Check the config:

```
### By default, it uses S3 on AWS.
# oc get configs.imageregistry.operator.openshift.io instance -o yaml | grep storageManaged -B3
    s3:
      bucket: image-registry-us-east-2-60a6ad0e25334332ae9ae079191ae4e2-a61c
      region: us-east-2
  storageManaged: true

```

Use the previous trick above with the modification of new `namespace` and `deployment`:

```

# oc create -n openshift-image-registry -f https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/registry_pvc.yaml
# oc get pvc -n openshift-image-registry
# oc set volume -n openshift-image-registry deploy/image-registry --add --name=registry-storage -t pvc --claim-name=registry --overwrite -m /registry

# curl -LO https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/registry_secret.yaml
# oc create secret generic dockerregistry --from-file=./registry_secret.yaml -n openshift-image-registry

# oc set volume -n openshift-image-registry deploy/image-registry --add --name=dockersecrets -m /etc/registryconfig --type=secret --secret-name=dockerregistry
# oc set env -n openshift-image-registry deploy/image-registry REGISTRY_CONFIGURATION_PATH=/etc/registryconfig/registry_secret.yaml

```

Testing:

```
### https://github.com/openshift/client-go/blob/master/examples/build/README.md#running-this-example
$ oc new-project testproject
### Create an app
$ oc new-app https://github.com/sclorg/cakephp-ex

### found nothing
# oc exec image-registry-755d488476-5fjqx -- ls /registry
lost+found
### also checked on the s3 console, it still pushes there

```

Created [issues/175](https://github.com/openshift/cluster-image-registry-operator/issues/175).

PVC will be supported by the operator, Cool. We do not need this trick anymore.

### Updated 20190325

[DEVEXP-203](https://jira.coreos.com/browse/DEVEXP-203) and [OCP-22653](https://polarion.engineering.redhat.com/polarion/#/project/OSE/workitem?id=OCP-22653).

Also
* asked about _ReadWriteMany_ in the above story.

  > Alex Gladkov:
  It can be ReadWriteOnce, but only if replicas == 1. But basically yes, registry needs ReadWriteMany.

* asked _travisn_ about _RWX_ via slack rook.

  > travisn:
  ceph-block does not support RWX while ceph-fs does.

  > Shyam:
  @hongkliu as long as `provisionVolume` is true as in https://github.com/ceph/ceph-csi/blob/csi-v1.0/examples/cephfs/storageclass.yaml#L19 it should work for dynamic provisioning. The storage class mentioned in the example should work as is (as long as secret.yaml contains the admin credentials  https://github.com/ceph/ceph-csi/blob/csi-v1.0/examples/cephfs/storageclass.yaml#L19 )

### Use gp2

[OCP-22653](https://polarion.engineering.redhat.com/polarion/#/project/OSE/workitem?id=OCP-22653)

```
$ kubectl api-resources --namespaced=false | grep imageregistry
configs                                           imageregistry.operator.openshift.io   false        Config
$ oc get configs.imageregistry.operator.openshift.io
NAME      AGE
cluster   108m

$ oc get configs.imageregistry.operator.openshift.io cluster -o json | jq -r .spec.storage
{
  "s3": {
    "bucket": "image-registry-us-east-2-32fa2a6702954c25b262136f56c52984-3468",
    "encrypt": true,
    "region": "us-east-2"
  }
}

### push a build
$ oc new-project testproject
$ oc new-app https://github.com/sclorg/cakephp-ex

### check on aws s3 console if it contains the contents
### https://s3.console.aws.amazon.com/s3/buckets/image-registry-us-east-2-32fa2a6702954c25b262136f56c52984-3468/?region=us-east-2&tab=overview

### NOT using this: oc patch configs.imageregistry.operator.openshift.io cluster -p '{"spec":{"storage":{"pvc":{"claim":""}}}}' --type='merge'
$ oc edit configs.imageregistry.operator.openshift.io cluster
  storage:                                                                                                       
    pvc:                                                                                                         
      claim: ""

$ oc get configs.imageregistry.operator.openshift.io cluster -o json | jq -r .spec.storage
{
  "pvc": {
    "claim": "image-registry-storage"
  }
}

$ oc get deploy image-registry 
NAME             READY   UP-TO-DATE   AVAILABLE   AGE
image-registry   1/1     1            1           129m

$ oc get pvc -n openshift-image-registry
NAME                     STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
image-registry-storage   Pending                                      gp2            7m22s
$ oc describe pvc -n openshift-image-registry image-registry-storage
Name:          image-registry-storage
Namespace:     openshift-image-registry
StorageClass:  gp2
Status:        Pending
Volume:        
Labels:        <none>
Annotations:   imageregistry.openshift.io: true
               volume.beta.kubernetes.io/storage-provisioner: kubernetes.io/aws-ebs
Finalizers:    [kubernetes.io/pvc-protection]
Capacity:      
Access Modes:  
Events:
  Type       Reason                Age                     From                         Message
  ----       ------                ----                    ----                         -------
  Warning    ProvisioningFailed    7m39s (x2 over 7m40s)   persistentvolume-controller  Failed to provision volume with StorageClass "gp2": invalid AccessModes [ReadWriteMany]: only AccessModes [ReadWriteOnce] are supported
  Normal     WaitForFirstConsumer  2m32s (x24 over 7m40s)  persistentvolume-controller  waiting for first consumer to be created before binding
Mounted By:  image-registry-f76466-jjjtn

```

Not working. Workaround:

```
$ oc project openshift-image-registry
$ oc get pvc image-registry-storage -o yaml > ~/pvc_reg.yaml
### Replace `ReadWriteMany` with `ReadWriteOnce`
$ vi ~/pvc_reg.yaml
$ oc delete pvc image-registry-storage
$ oc create -f ~/pvc_reg.yaml

$ oc get pod -l docker-registry=default
NAME                          READY   STATUS    RESTARTS   AGE
image-registry-f76466-mxmtj   1/1     Running   0          41m

$ oc set volume pod image-registry-f76466-mxmtj | grep pvc -A1
  pvc/image-registry-storage (allocated 100GiB) as registry-storage
    mounted at /registry

$ oc exec image-registry-f76466-mxmtj -- ls /registry
lost+found

$ oc start-build -n testproject cakephp-ex
$ oc exec image-registry-f76466-mxmtj -- ls /registry
docker
lost+found

```

### Use ceph-fs

```
### TODO
```
