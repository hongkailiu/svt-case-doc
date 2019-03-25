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

Updated 20190325:

[DEVEXP-203](https://jira.coreos.com/browse/DEVEXP-203) and [OCP-22653](https://polarion.engineering.redhat.com/polarion/#/project/OSE/workitem?id=OCP-22653).

Also
* asked about _ReadWriteMany_ in the above story.
  ```
  Alex Gladkov:
  It can be ReadWriteOnce, but only if replicas == 1. But basically yes, registry needs ReadWriteMany.
  ```
* asked _travisn_ about _RWX_ via slack rook.


