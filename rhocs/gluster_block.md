# Gluster-Block

## Run playbook to load modules and to start services

```sh
### inv.file contains all nodes in the cluster
$ ansible-playbook -i inv.file playbooks/gluster_block_pre.yml
```

Those are prerequisites for those service to run in glusterfs pods:

```sh
$ systemctl status glusterd gluster-blockd tcmu-runner gluster-block-target
```

## Deploy CNS via playbook
Check [glusterFS.md](glusterFS.md) for details:

```
glusterfs_devices=["/dev/xvdf"]
openshift_storage_glusterfs_wipe=true
openshift_storage_glusterfs_image=registry.access.redhat.com/rhgs3/rhgs-server-rhel7
openshift_storage_glusterfs_version=3.3.0-362
openshift_storage_glusterfs_heketi_image=registry.access.redhat.com/rhgs3/rhgs-volmanager-rhel7
openshift_storage_glusterfs_heketi_version=3.3.0-364
openshift_hosted_registry_glusterfs_swap=true
openshift_storage_glusterfs_block_deploy=True
openshift_storage_glusterfs_block_image=registry.access.redhat.com/rhgs3/rhgs-gluster-block-prov-rhel7
openshift_storage_glusterfs_block_version=3.3.0-362
openshift_storage_glusterfs_block_host_vol_size=800
```

Now we create `sc` _glusterblock_:

```sh
# oc project glusterfs
### get the secretName
# oc get sc glusterfs-storage -o yaml | grep secretName: | awk '{print $2}'
heketi-storage-admin-secret

# oc get secret heketi-storage-admin-secret -o yaml > glusterblock_secret.yaml
### modify name, selfLink and type
# vi glusterblock_secret.yaml
apiVersion: v1
data:
  key: NkJqZVRtMG5EcFhYRC9EdWJpMDc2YnZONCtRNldQZEw3UjhTWVFFSzdEZz0=
kind: Secret
metadata:
  creationTimestamp: 2018-01-12T19:14:32Z
  name: heketi-storage-admin-secreta
  namespace: glusterfs
  resourceVersion: "7074"
  selfLink: /api/v1/namespaces/glusterfs/secrets/heketi-storage-admin-secreta
  uid: d22bc846-f7cc-11e7-ae9c-028542dcc35e
type: gluster.org/glusterblock

# oc create -f glusterblock_secret.yaml

### Get the decoded secret
# oc get secret -n glusterfs heketi-storage-admin-secret -o yaml | grep key | awk '{print $2}' | base64 --decode
6BjeTm0nDpXXD/Dubi076bvN4+Q6WPdL7R8SYQEK7Dg=

### Get heketi url
# oc get sc glusterfs-storage -o yaml | grep resturl | awk '{print $2}'
http://heketi-storage-glusterfs.apps.0112-xte.qe.rhcloud.com

# oc rsh heketi-storage-1-xbb7m
sh-4.2# heketi-cli --server http://heketi-storage-glusterfs.apps.0112-xte.qe.rhcloud.com --user admin --secret 6BjeTm0nDpXXD/Dubi076bvN4+Q6WPdL7R8SYQEK7Dg= cluster list
Clusters:
Id:4690bc83f8c06bc09d840ede8e2f3784 [file][block]

### Modify clusterids, resturl
# vi sc_glusterblock.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: glusterblock
  selfLink: /apis/storage.k8s.io/v1/storageclasses/glusterblock
parameters:
  chapauthenabled: "true"
  clusterids: 4690bc83f8c06bc09d840ede8e2f3784
  hacount: "3"
  restsecretname: heketi-storage-admin-secreta
  restsecretnamespace: glusterfs
  resturl: http://heketi-storage-glusterfs.apps.0112-xte.qe.rhcloud.com
  restuser: admin
provisioner: gluster.org/glusterblock

# oc create -f sc_glusterblock.yaml
```

Then create PVC:

```sh
### create PVC based on glusterblock
# oc create -f https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/pvc_glusterblock.yaml
```

## Prove it is block-volume
Logs from hekiti pod:

```sh
### watch heketi pod logs: keywords "Command: gluster-block create"
# oc logs -f heketi-storage-1-xbb7m
...
[kubeexec] DEBUG 2018/01/12 20:07:14 /src/github.com/heketi/heketi/executors/kubeexec/kubeexec.go:250: Host: ip-172-31-19-193.us-west-2.compute.internal Pod: glusterfs-storage-rd2qr Command: gluster-block create vol_19358103e4767c7f3363b43c8e2833c4/blockvol_7733dc8cd6244c17afb8ef3f57d9b86e  ha 3 auth enable prealloc full 172.31.19.193,172.31.27.35,172.31.46.22 2G --json
Result: { "IQN": "iqn.2016-12.org.gluster-block:22e7f729-51c9-4ca7-b55b-1f2e57087f8f", "USERNAME": "22e7f729-51c9-4ca7-b55b-1f2e57087f8f", "PASSWORD": "de00be08-df1e-4378-a9cd-45d7bb122839", "PORTAL(S)": [ "172.31.19.193:3260", "172.31.27.35:3260", "172.31.46.22:3260" ], "RESULT": "SUCCESS" }
[heketi] INFO 2018/01/12 20:07:14 Created block volume 7733dc8cd6244c17afb8ef3f57d9b86e
...
```

PV's description:

```sh
# oc get pvc
NAME          STATUS    VOLUME                                     CAPACITY   ACCESSMODES   STORAGECLASS   AGE
pvc-gluster   Bound     pvc-23c8e92f-f7d4-11e7-ae9c-028542dcc35e   1Gi        RWO           glusterblock   24s

# oc get pv
NAME                                       CAPACITY   ACCESSMODES   RECLAIMPOLICY   STATUS    CLAIM                   STORAGECLASS   REASON    AGE
pvc-23c8e92f-f7d4-11e7-ae9c-028542dcc35e   1Gi        RWO           Delete          Bound     glusterfs/pvc-gluster   glusterblock             5m

### keywords: ISCSI
# oc describe pv pvc-23c8e92f-f7d4-11e7-ae9c-028542dcc35e
Name:		pvc-23c8e92f-f7d4-11e7-ae9c-028542dcc35e
Labels:		<none>
Annotations:	AccessKey=glusterblk-22e7f729-51c9-4ca7-b55b-1f2e57087f8f-secret
		AccessKeyNs=glusterfs
		Blockstring=url:http://heketi-storage-glusterfs.apps.0112-xte.qe.rhcloud.com,user:admin,secret:heketi-storage-admin-secreta,secretnamespace:glusterfs
		Description=Gluster-external: Dynamically provisioned PV
		gluster.org/type=block
		glusterBlkProvIdentity=gluster.org/glusterblock
		glusterBlockShare=blockvol_7733dc8cd6244c17afb8ef3f57d9b86e
		kubernetes.io/createdby=heketi
		pv.kubernetes.io/provisioned-by=gluster.org/glusterblock
		v1.0.0=v1.0.0
StorageClass:	glusterblock
Status:		Bound
Claim:		glusterfs/pvc-gluster
Reclaim Policy:	Delete
Access Modes:	RWO
Capacity:	1Gi
Message:
Source:
    Type:		ISCSI (an ISCSI Disk resource that is attached to a kubelet's host machine and then exposed to the pod)
    TargetPortal:	172.31.19.193
    IQN:		iqn.2016-12.org.gluster-block:22e7f729-51c9-4ca7-b55b-1f2e57087f8f
    Lun:		0
    ISCSIInterface	default
    FSType:		xfs
    ReadOnly:		false
    Portals:		[172.31.27.35 172.31.46.22]
    DiscoveryCHAPAuth:	false
    SessionCHAPAuth:	true
    SecretRef:		&{glusterblk-22e7f729-51c9-4ca7-b55b-1f2e57087f8f-secret}
Events:			<none>
```

Output from heketi-cli:

```sh
# oc rsh heketi-storage-1-xbb7m

sh-4.2# heketi-cli --version
heketi-cli 5.0.0

### volume with "[block]"
sh-4.2# heketi-cli --server http://heketi-storage-glusterfs.apps.0112-xte.qe.rhcloud.com --user admin --secret 6BjeTm0nDpXXD/Dubi076bvN4+Q6WPdL7R8SYQEK7Dg= volume list
        Id:19358103e4767c7f3363b43c8e2833c4    Cluster:4690bc83f8c06bc09d840ede8e2f3784    Name:vol_19358103e4767c7f3363b43c8e2833c4 [block]
        Id:8316417d80cfbe08edfbe3e4589a85e0    Cluster:4690bc83f8c06bc09d840ede8e2f3784    Name:heketidbstorage

sh-4.2# heketi-cli --server http://heketi-storage-glusterfs.apps.0112-xte.qe.rhcloud.com --user admin --secret 6BjeTm0nDpXXD/Dubi076bvN4+Q6WPdL7R8SYQEK7Dg= volume info 19358103e4767c7f3363b43c8e2833c4
Name: vol_19358103e4767c7f3363b43c8e2833c4
Size: 800
Volume Id: 19358103e4767c7f3363b43c8e2833c4
Cluster Id: 4690bc83f8c06bc09d840ede8e2f3784
Mount: 172.31.19.193:vol_19358103e4767c7f3363b43c8e2833c4
Mount Options: backup-volfile-servers=172.31.27.35,172.31.46.22
Block: true
Free Size: 798
Block Volumes: [7733dc8cd6244c17afb8ef3f57d9b86e]
Durability Type: replicate
Distributed+Replica: 3

```

# References

[1]. [Block-storage](https://access.redhat.com/documentation/en-us/red_hat_gluster_storage/3.3/html-single/container-native_storage_for_openshift_container_platform/#Block_Storage)
