# GlusterFS

## DOC

* [gluster-storage@redhat](https://access.redhat.com/documentation/en/red-hat-gluster-storage/)
* [glusterFS@Wiki](https://en.wikipedia.org/wiki/GlusterFS)
* [gluster.org](https://www.gluster.org/): [doc@gluster.org](https://docs.gluster.org/en/latest/)
    * [replica-2-and-replica-3-volumes](https://docs.gluster.org/en/v3/Administrator%20Guide/arbiter-volumes-and-quorum/#replica-2-and-replica-3-volumes)
* [glusterFS@oc](https://docs.openshift.com/container-platform/3.6/install_config/persistent_storage/persistent_storage_glusterfs.html)
    * containerized cluster, or containerized native storage (CNS): [containerized cluster](https://access.redhat.com/documentation/en-us/red_hat_gluster_storage/3.1/html/container-native_storage_for_openshift_container_platform_3.4/)
    * dedicated cluster
* [heketi](https://github.com/heketi/heketi)
* [brick-multiplexing](http://blog.gluster.org/brick-multiplexing-in-gluster-3-10/)
* gluster-block: [design doc](https://github.com/gluster/gluster-kubernetes/blob/master/docs/design/gluster-block-provisioning.md), [repo](https://github.com/gluster/gluster-block/)
* [cns@rh.blog](https://redhatstorage.redhat.com/2017/10/05/container-native-storage-for-the-openshift-masses/)
* [Good notes](https://github.com/RedHatWorkshops/openshiftv3-ops-workshop/blob/master/cns.md) sent by Elko
* [CNS and CRS](https://access.redhat.com/documentation/en-us/reference_architectures/2017/html/deploying_and_managing_openshift_container_platform_3.6_on_amazon_web_services/persistent_storage)
* heketi troubleshooting doc: [mojo@rh](https://mojo.redhat.com/docs/DOC-1165175-cns-container-native-storage-troubleshootingdebugging-guide) and [heketi-doc@gh](https://github.com/heketi/heketi/blob/263fbb72055d71b3763a77c051e7a00cf0c4e436/docs/troubleshooting.md) and [Raghavendra's notes](https://docs.google.com/document/d/1_kNpUyqz95wvjYWMkQieDEEdLj0atRvaPLzFcan5tBI/edit#heading=h.96vxedwcaacv)

## CNS

### Installation
At least 3 glusterfs nodes in the installation, otherwise:

```
TASK [openshift_storage_glusterfs : assert] *********************************************************************************
...
MSG:

There must be at least three GlusterFS nodes specified
```

#### [Ansible](https://docs.openshift.com/container-platform/3.6/install_config/install/advanced_install.html#advanced-install-glusterfs-persistent-storage)

Launch 5 EC2 instances:

```sh
aws ec2 run-instances --image-id ami-6ca0ba15 \
    --security-group-ids sg-5c5ace38 --count 5 --instance-type m4.xlarge --key-name id_rsa_perf \
    --subnet subnet-4879292d \
    --block-device-mappings "[{\"DeviceName\":\"/dev/sdb\", \"Ebs\":{\"VolumeSize\": 30}},{\"DeviceName\":\"/dev/sdf\", \"Ebs\":{\"VolumeSize\": 30}}]" \
    --query 'Instances[*].InstanceId' \
    --tag-specifications="[{\"ResourceType\":\"instance\",\"Tags\":[{\"Key\":\"Name\",\"Value\":\"qe-hongkliu-bbb-0822\"}]}]"  
```

Note that block device <code>/dev/sdf</code> is managed by GlusterFS cluster.

Change the inventory file: 2.file

```
[OSEv3:children]
...
glusterfs


[OSEv3:vars]
...
glusterfs_devices=["/dev/xvdf"]
openshift_storage_glusterfs_wipe=true
openshift_storage_glusterfs_image=registry.access.redhat.com/rhgs3/rhgs-server-rhel7
openshift_storage_glusterfs_version=latest
openshift_storage_glusterfs_heketi_image=registry.access.redhat.com/rhgs3/rhgs-volmanager-rhel7
openshift_storage_glusterfs_heketi_version=latest
openshift_hosted_registry_glusterfs_swap=true
##since Nov 22, 2017
openshift_storage_glusterfs_block_deploy=False
openshift_storage_glusterfs_block_image=registry.access.redhat.com/rhgs3/rhgs-gluster-block-prov-rhel7
openshift_storage_glusterfs_block_version=3.3.0-362

...
[glusterfs]
ec2-54-202-90-213.us-west-2.compute.amazonaws.com
ec2-54-200-102-250.us-west-2.compute.amazonaws.com
ec2-54-213-42-122.us-west-2.compute.amazonaws.com
```

[More parameters](https://github.com/openshift/openshift-ansible/tree/master/roles/openshift_storage_glusterfs) in the role <code>openshift_storage_glusterfs</code>. [Example of the inventory file](https://github.com/openshift/openshift-ansible/blob/master/inventory/byo/hosts.byo.glusterfs.storage-and-registry.example).

Run playbook (on master):

```sh
# ansible-playbook -i /tmp/2.file openshift-ansible/playbooks/byo/config.yml
```

Check project <code>glusterfs</code>

```sh
# oc get daemonset 
NAME                DESIRED   CURRENT   READY     UP-TO-DATE   AVAILABLE   NODE-SELECTOR            AGE
glusterfs-storage   3         3         3         3            3           glusterfs=storage-host   13m
# oc get all -n glusterfs -o wide
NAME                REVISION   DESIRED   CURRENT   TRIGGERED BY
dc/heketi-storage   1          1         1         config

NAME                  DESIRED   CURRENT   READY     AGE       CONTAINER(S)   IMAGE(S)                             SELECTOR
rc/heketi-storage-1   1         1         1         1h        heketi         rhgs3/rhgs-volmanager-rhel7:latest   deployment=heketi-storage-1,deploymentconfig=heketi-storage,glusterfs=heketi-storage-pod

NAME                    HOST/PORT                                       PATH      SERVICES         PORT      TERMINATION   WILDCARD
routes/heketi-storage   heketi-storage-glusterfs.54.245.157.96.xip.io             heketi-storage   heketi                  None

NAME                              CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE       SELECTOR
svc/heketi-db-storage-endpoints   172.24.85.211   <none>        1/TCP      1h        <none>
svc/heketi-storage                172.24.37.13    <none>        8080/TCP   1h        glusterfs=heketi-storage-pod

NAME                         READY     STATUS    RESTARTS   AGE       IP              NODE
po/glusterfs-storage-bm10c   1/1       Running   0          1h        172.31.48.172   ip-172-31-48-172.us-west-2.compute.internal
po/glusterfs-storage-pjz47   1/1       Running   0          1h        172.31.17.109   ip-172-31-17-109.us-west-2.compute.internal
po/glusterfs-storage-qsg6l   1/1       Running   0          1h        172.31.44.251   ip-172-31-44-251.us-west-2.compute.internal
po/heketi-storage-1-xmgdg    1/1       Running   0          1h        172.20.0.3      ip-172-31-44-251.us-west-2.compute.internal

# oc get storageclass glusterfs-storage -o yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  creationTimestamp: 2017-08-22T18:33:18Z
  name: glusterfs-storage
  resourceVersion: "5005"
  selfLink: /apis/storage.k8s.io/v1/storageclasses/glusterfs-storage
  uid: 5e1503ba-8768-11e7-975f-025caffb13f6
parameters:
  resturl: http://heketi-storage-glusterfs.54.245.157.96.xip.io
  restuser: admin
  secretName: heketi-storage-admin-secret
  secretNamespace: glusterfs
provisioner: kubernetes.io/glusterfs

```

_Note_ that

* Each _glusterfs_ node has <code>po/glusterfs-storage-\*</code> and one of them has <code>po/heketi-storage-1-\*</code>.
* SC _glusterfs-storage_ connects to rest api provided by heketi to provion storage. Check the route:

   ```sh
   # curl http://heketi-storage-glusterfs.54.245.157.96.xip.io
   Required authorization token not found
   ```

Create pvc (using [pvc_gluster.yaml](../files/pvc_gluster.yaml)) and use it in a pod ([pod_jenkins_volume.yaml](../files/pod_jenkins_volume.yaml)).

```sh
# oc new-project aaa
# oc create -f pvc_gluster.yaml
# oc get pvc
NAME          STATUS    VOLUME                                     CAPACITY   ACCESSMODES   STORAGECLASS        AGE
pvc-gluster   Bound     pvc-8744683b-8768-11e7-975f-025caffb13f6   1Gi        RWO           glusterfs-storage   17m
# oc get pv
NAME                                       CAPACITY   ACCESSMODES   RECLAIMPOLICY   STATUS    CLAIM             STORAGECLASS        REASON    AGE
pvc-8744683b-8768-11e7-975f-025caffb13f6   1Gi        RWO           Delete          Bound     aaa/pvc-gluster   glusterfs-storage             18m

# #This is interesting: When PVC is created, a svc is created with it.
# oc get service
NAME                            CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
glusterfs-dynamic-pvc-gluster   172.27.199.64   <none>        1/TCP      2m
# #It will be deleted when the pvc is deleted.

# #replace claimName: pvc-ebs by claimName: pvc-gluster
# oc create -f pod_jenkins_volume.yaml
# oc get pod 
NAME               READY     STATUS    RESTARTS   AGE
web                1/1       Running   0          1m
# oc volumes pod web
pods/web
  pvc/pvc-gluster (allocated 1GiB) as ddd
    mounted at /var/jenkins_home
  secret/default-token-gj7td as default-token-gj7td
    mounted at /var/run/secrets/kubernetes.io/serviceaccount
# #check if the data is written on the volume
# oc exec web -- ls /var/jenkins_home
```

#### [Deploy on existing cluster](https://github.com/openshift/openshift-ansible/tree/master/playbooks/byo/openshift-glusterfs)

```sh
# ansible-playbook -i /tmp/2.file openshift-ansible/playbooks/byo/openshift-glusterfs/config.yml
### 3.9+
# ansible-playbook -i /tmp/2.file openshift-ansible/playbooks/openshift-glusterfs/config.yml
```

Difference on config.yml and registry.yml in [playbooks/byo/openshift-glusterfs](https://github.com/openshift/openshift-ansible/tree/master/playbooks/byo/openshift-glusterfs), quoting Comment 8 from [bz](https://bugzilla.redhat.com/show_bug.cgi?id=1507628):

> Jose A. Rivera: config.yml will setup a GlusterFS cluster managed by heketi and (by default) create a StorageClass that will use it. registry.yml will setup a GlusterFS cluster managed by heketi without a StorageClass (by default) AND it will create a volume that is intended for use as storage for a hosted registry. registry.yml uses all the same ansible as config.yml with slightly different defaults and then adds a few more tasks on top of that.


#### [cns-deploy](cns_deploy.md)

### Heketi

#### Heketi client

Install:

On <code>fedora 26</code>:

```sh
$ sudo dnf install heketi-client
```

On <code>gold-AMI</code>:

```sh
# yum heketi-cli
```

Or, on plain rhel:

```sh
$ curl -L -o heketi-client-v4.0.0.linux.amd64.tar.gz https://github.com/heketi/heketi/releases/download/v4.0.0/heketi-client-v4.0.0.linux.amd64.tar.gz
$ tar xzvf heketi-client-v4.0.0.linux.amd64.tar.gz
$ ./heketi-client/bin/heketi-cli --version
heketi-cli v4.0.0
```

Get heketi url and token:

```sh
# oc get storageclass glusterfs-storage -o yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  creationTimestamp: 2017-08-25T14:38:05Z
  name: glusterfs-storage
  resourceVersion: "1869"
  selfLink: /apis/storage.k8s.io/v1/storageclasses/glusterfs-storage
  uid: 019ca86f-89a3-11e7-8705-0279b0aa6374
parameters:
  resturl: http://heketi-storage-glusterfs.0825-0lo.qe.rhcloud.com
  restuser: admin
  secretName: heketi-storage-admin-secret
  secretNamespace: glusterfs
provisioner: kubernetes.io/glusterfs

# oc get secret -n glusterfs heketi-storage-admin-secret -o yaml | grep key | awk '{print $2}' | base64 --decode 
0WTWPMxPtKWzjAoK+MUGVOPkw3RJ3TLvzBlHAJaTxqs=

# heketi-cli --server http://heketi-storage-glusterfs.0825-0lo.qe.rhcloud.com --user admin --secret 0WTWPMxPtKWzjAoK+MUGVOPkw3RJ3TLvzBlHAJaTxqs= cluster list
Clusters:
6fac9ed1dd16ff1c330789c2e6494552

# heketi-cli topology info
sh-4.2# heketi-cli --server http://heketi-storage-glusterfs.apps.0119-i4t.qe.rhcloud.com --user admin --secret PWDgVBQlPLrvjEvrPnlqOnOGT3e9qTwczgG9xceUI6U= topology info | grep -E "Node Id|State"
```

Via [curl command](https://github.com/heketi/heketi/wiki/API#authentication-model-):

```sh
$ python -V
Python 2.7.5

$ #Suggested to do in virtualenv
$ pip install PyJWT

$ #cp the python example:
# #change the secret
$ vi exmaple.py
...
uri = '/clusters'
secret = '0WTWPMxPtKWzjAoK+MUGVOPkw3RJ3TLvzBlHAJaTxqs='
...

$ #generate the jwt string
$ python exmaple.py
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJhZG1pbiIsImlhdCI6MTUwMzY5MTM5MCwicXNoIjoiNDc0OWE1OWRlODdjMjdjOWIyZjQ5NWM1ZjEzMDliMjUyNTY4MWRmZTMwYzhhN2I4MzYyNTkwMWIxMzJhOWMyNiIsImV4cCI6MTUwMzY5MTk5MH0.M_33aTu_hHu9amt-Pmp2idWsKVkP3Sckf4EUkMGgsWk

$ curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJhZG1pbiIsImlhdCI6MTUwMzY5MTM5MCwicXNoIjoiNDc0OWE1OWRlODdjMjdjOWIyZjQ5NWM1ZjEzMDliMjUyNTY4MWRmZTMwYzhhN2I4MzYyNTkwMWIxMzJhOWMyNiIsImV4cCI6MTUwMzY5MTk5MH0.M_33aTu_hHu9amt-Pmp2idWsKVkP3Sckf4EUkMGgsWk" http://heketi-storage-glusterfs.0825-0lo.qe.rhcloud.com/clusters
{"clusters":["6fac9ed1dd16ff1c330789c2e6494552"]}

```

When generate jwt string, the <code>url</code> has to match the one in the url command. If the return of the curl command is _Token is expired_, we have to regenerate the jwt string.

### CNS and device-mapper

CNS requires device-mapper. It requires <code>modprobe dm_thin_pool</code> on each glusterfs nodes ~~(maybe heketi nodes as well)~~. Otherwise, we would meet [this issue](https://github.com/openshift/openshift-ansible/issues/5108) which is reported on [this bug](https://bugzilla.redhat.com/show_bug.cgi?id=1490905). When our docker uses overlay2 (not device-mapper) as storage driver, we run into this issue. Until [PR#5720](https://github.com/openshift/openshift-ansible/pull/5720) is merged, we can run [this playbook](https://github.com/hongkailiu/svt-case-doc/tree/master/playbooks#launch-device-mapper-module) to load the missing module.

### Use CNS as storage for docker registery
See [here](../learn/docker_registry.md#glusterfs-as-docker-registery-storage) for details.

## GlusterFS

### [Installation](https://access.redhat.com/documentation/en-US/Red_Hat_Storage/3/html/Administration_Guide/part-Red_Hat_Storage_Administration_on_Public_Cloud.html)

### Integration with OpenShift






## Reference
[1]. [RH Storage Server](https://access.redhat.com/documentation/en-US/Red_Hat_Storage/3/html/Administration_Guide/index.html)

[2]. [CNS: Architecture and configuration guide](https://www.redhat.com/cms/managed-files/st-container-native-storage-technology-detail-inc0464300at-201611-v2-en.pdf)

