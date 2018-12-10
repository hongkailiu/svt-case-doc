# Operators for OCP Storage system

## Doc

* [epic@jira](https://jira.coreos.com/browse/PROD-597)
* [introducing-volume-snapshot-alpha-for-kubernetes](https://kubernetes.io/blog/2018/10/09/introducing-volume-snapshot-alpha-for-kubernetes/)
* Flex volume: [intro](https://itnext.io/how-to-create-a-custom-persistent-volume-plugin-in-kubernetes-via-flexvolume-part-1-f6d9d966e123), [FlexVolue@oc](https://docs.openshift.com/container-platform/3.11/install_config/persistent_storage/persistent_storage_flex_volume.html), [FV@blog](http://leebriggs.co.uk/blog/2017/03/12/kubernetes-flexvolumes.html)
* [kubernetes-csi/docs](https://github.com/kubernetes-csi/docs), [oc-csi](https://docs.openshift.com/container-platform/3.11/install_config/persistent_storage/persistent_storage_csi.html)
* [gluster/gluster-csi-driver](https://github.com/gluster/gluster-csi-driver) 
* block-volume: [BV@oc](https://docs.openshift.com/container-platform/3.11/architecture/additional_concepts/storage.html#block-volume-support), [BV@k8s](https://www.youtube.com/watch?v=k8_QQ9eNa-g)
* [External PV Provisioners](https://docs.openshift.com/container-platform/3.11/install_config/provisioners.html), [external-storage: aws/efs](https://github.com/kubernetes-incubator/external-storage/tree/master/aws/efs)
* sc: local: [local@k8s](https://kubernetes.io/docs/concepts/storage/storage-classes/#local); [local@oc](https://docs.openshift.com/container-platform/3.11/install_config/configuring_local.html)
* [aws: ebs vs efs](https://n2ws.com/blog/ebs-snapshot/aws-fast-storage-efs-vs-ebs), [efs.doc](https://docs.aws.amazon.com/efs/latest/ug/using-fs.html)

## PV using local storage

Add a 100G block device to an instance: [steps](../cloud/ec2/ec2.md#useful-commands).

```bash
# lsblk 
NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
...
nvme2n1     259:4    0  100G  0 disk 

### add 2 partitions on /dev/nvme2n1
# fdisk /dev/nvme2n1
# cat /proc/partitions 
major minor  #blocks  name
...
 259        4  104857600 nvme2n1
 259        5   31457280 nvme2n1p1
 259        6   73399296 nvme2n1p2

# mkfs.ext4 /dev/nvme2n1p1
# mkdir -p /mnt/local-storage/ssd/disk1
# echo "/dev/nvme2n1p1 /mnt/local-storage/ssd/disk1 ext4 defaults 1 2" >> /etc/fstab
# mount -a

```

Follow the steps in [oc doc](https://docs.openshift.com/container-platform/3.11/install_config/configuring_local.html):

```bash
# chcon -R unconfined_u:object_r:svirt_sandbox_file_t:s0 /mnt/local-storage/


# oc new-project local-storage
# oc create -f https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/local_volume_config_cm.yaml
# oc create serviceaccount local-storage-admin
# oc adm policy add-scc-to-user privileged -z local-storage-admin
# oc create -f https://raw.githubusercontent.com/openshift/origin/release-3.11/examples/storage-examples/local-examples/local-storage-provisioner-template.yaml

# oc new-app -p CONFIGMAP=local-volume-config \
  -p SERVICE_ACCOUNT=local-storage-admin \
  -p NAMESPACE=local-storage \
  -p PROVISIONER_IMAGE=registry.reg-aws.openshift.com:443/openshift3/local-storage-provisioner:v3.11 \
  local-storage-provisioner

# oc get all
NAME                                 READY     STATUS    RESTARTS   AGE
pod/local-volume-provisioner-9zj8j   1/1       Running   0          9s

NAME                                      DESIRED   CURRENT   READY     UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
daemonset.apps/local-volume-provisioner   1         1         1         1            1           <none>          9s

# oc create -f https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/local_ssd_sc.yaml

# oc get sc local-ssd
NAME        PROVISIONER                    AGE
local-ssd   kubernetes.io/no-provisioner   16s
```

[Creating Local Persistent Volume Claim](https://docs.openshift.com/container-platform/3.11/install_config/persistent_storage/persistent_storage_local.html#install-config-persistent-storage-persistent-storage-local):

```bash
### create PVC
# oc process -f https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/pvc_template.yaml -p STORAGE_CLASS_NAME=local-ssd -p PVC_NAME=abc | oc create -f -
# oc get pvc
NAME      STATUS    VOLUME    CAPACITY   ACCESS MODES   STORAGECLASS   AGE
abc       Pending                                       local-ssd      1m

### The PVC will be pending until a pod using it gets created
### https://kubernetes.io/blog/2018/04/13/local-persistent-volumes-beta/
### The above blog also states that local volume should work without the provisioner
# oc create -f https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/dc_centos_with_pv.yaml

# oc get pod
NAME                             READY     STATUS    RESTARTS   AGE
centos-1-65vm5                   1/1       Running   0          2m
local-volume-provisioner-9zj8j   1/1       Running   0          39m

# oc get pvc
NAME      STATUS    VOLUME              CAPACITY   ACCESS MODES   STORAGECLASS   AGE
abc       Bound     local-pv-7b774915   29Gi       RWO            local-ssd      14m

# oc get pv
NAME                CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS    CLAIM               STORAGECLASS   REASON    AGE
local-pv-7b774915   29Gi       RWO            Delete           Bound     local-storage/abc   local-ssd                40m

```

Observation:

* The provisioner provided by Openshift is creating PV on requesting PVC with the storage class.
* The size is determined by the mount device, instead of the requested size in PVC yaml.

Clean up:

```bash
# oc delete dc centos
# oc delete pvc abc
# The PV will be deleted automatically
# oc get pv
No resources found.
# oc delete project local-storage

```

This local volume provisioner also supports to [provision raw block devices](https://docs.openshift.com/container-platform/3.11/install_config/configuring_local.html#local-volume-raw-block-devices).

```bash
### tested on 20181031
# vi oc edit cm node-config-infra -n openshift-node
apiServerArguments:
   feature-gates:
   - BlockVolume=true
...

 controllerArguments:
   feature-gates:
   - BlockVolume=true
...

### edit the configMap which fits your cluster
# oc get cm  -n openshift-node
NAME                            DATA      AGE
node-config-all-in-one          1         2h
node-config-all-in-one-crio     1         2h
node-config-compute             1         2h
node-config-compute-crio        1         2h
node-config-infra               1         2h
node-config-infra-crio          1         2h
node-config-master              1         2h
node-config-master-crio         1         2h
node-config-master-infra        1         2h
node-config-master-infra-crio   1         2h

# check which one is being used on a node (thanks to Mike)
# grep BOOTSTRAP_CONFIG_NAME /etc/sysconfig/atomic-openshift-node 
BOOTSTRAP_CONFIG_NAME=node-config-all-in-one
# oc edit cm node-config-all-in-one -n openshift-node
kubeletArguments:
   feature-gates:
   - RotateKubeletClientCertificate=true,RotateKubeletServerCertificate=true,BlockVolume=true


# master-restart controllers controllers
# master-restart api api
### verify if the api and the controller pods get increased for `RESTARTS`
# oc get pod -n kube-system

### the doc said the node is auto-restarted after changing the CM
### this can be verified by:
# systemctl status atomic-openshift-node.service
### check time in line: Active: active (running) since Wed 2018-10-31 17:54:15 UTC; 16min ago
### get the pid (9273) and check `,BlockVolume=true` is in the command parameter
# ps auxwww | grep 9273


# lsblk 
NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
...
nvme2n1     259:1    0  100G  0 disk 
nvme3n1     259:3    0  100G  0 disk 
nvme4n1     259:6    0  100G  0 disk 

# mkdir -p /mnt/local-storage/block-devices
# ln -s /dev/nvme3n1 /mnt/local-storage/block-devices/nvme3n1

# chcon -R unconfined_u:object_r:svirt_sandbox_file_t:s0 /mnt/local-storage/
# chcon unconfined_u:object_r:svirt_sandbox_file_t:s0 /dev/nvme3n1

# oc new-project local-storage

# oc create serviceaccount local-storage-admin
# oc adm policy add-scc-to-user privileged -z local-storage-admin

# oc create -f https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/local_volume_config_cm.yaml
# oc create -f https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/block_devices_sc.yaml
# curl -LO https://raw.githubusercontent.com/openshift/origin/release-3.11/examples/storage-examples/local-examples/local-storage-provisioner-template.yaml
# vi local-storage-provisioner-template.yaml

# oc create -f local-storage-provisioner-template.yaml

# oc new-app -p CONFIGMAP=local-volume-config   -p SERVICE_ACCOUNT=local-storage-admin   -p NAMESPACE=local-storage   -p PROVISIONER_IMAGE=registry.reg-aws.openshift.com:443/openshift3/local-storage-provisioner:v3.11   local-storage-provisioner

### create PVC: note that "-p VOLUME_MODE=Block"
# oc process -f https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/pvc_template.yaml -p STORAGE_CLASS_NAME=block-devices -p PVC_NAME=abc -p VOLUME_MODE=Block | oc create -f -
# oc create -f https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/dc_centos_with_block_device.yaml

# oc get pod
NAME                             READY     STATUS    RESTARTS   AGE
centos-1-nqqhk                   1/1       Running   0          23s
local-volume-provisioner-8d9qb   1/1       Running   0          43m
root@ip-172-31-16-58: ~ # oc get pv
NAME                CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS    CLAIM               STORAGECLASS    REASON    AGE
local-pv-fd3708f8   100Gi      RWO            Delete           Bound     local-storage/abc   block-devices             6m
root@ip-172-31-16-58: ~ # oc get pvc
NAME      STATUS    VOLUME              CAPACITY   ACCESS MODES   STORAGECLASS    AGE
abc       Bound     local-pv-fd3708f8   100Gi      RWO            block-devices   2m


```

Created [12730](https://github.com/openshift/openshift-docs/issues/12730) and blocked by [12731](https://github.com/openshift/openshift-docs/issues/12730).

## External provisioner

Currently it has only efs provisioner. 
Suppose we have an efs with fs-id: fs-2a886d82 (see [efs.md](../cloud/ec2/efs.md) for details).
The folder `/data/persistentvolumes` must exist on the efs.
Let us deploy the provision on opc (see [more vars](https://github.com/openshift/openshift-ansible/tree/release-3.11/roles/openshift_provisioners)):

```sh
# ansible-playbook -v -i /tmp/2.file \
      /root/openshift-ansible/playbooks/openshift-provisioners/config.yml \
     -e openshift_provisioners_install_provisioners=True \
     -e openshift_provisioners_efs=True \
     -e openshift_provisioners_efs_fsid=fs-2a886d82 \
     -e openshift_provisioners_efs_region=us-west-2 \
     -e openshift_provisioners_efs_aws_access_key_id=<money> \
     -e openshift_provisioners_efs_aws_secret_access_key=<money> \
     -e openshift_provisioners_efs_path=/data/persistentvolumes

###pod is not running
# oc get pod -n openshift-infra

###Workaround: edit dc to use reg-aws reg
# oc get dc -n openshift-infra provisioners-efs -o yaml | grep image:
        image: registry.reg-aws.openshift.com:443/openshift3/efs-provisioner:latest

###move the pod to infra node: optional
# oc patch dc -n openshift-infra provisioners-efs --patch '{"spec": {"template": {"spec": {"nodeSelector": {"node-role.kubernetes.io/infra": "true"}}}}}'

# oc get pod -n openshift-infra
NAME                       READY     STATUS    RESTARTS   AGE
provisioners-efs-2-sx8lg   1/1       Running   0          10m


# oc create -f https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/sc_aws_efs.yaml
# oc get sc aws-efs 
NAME      PROVISIONER             AGE
aws-efs   openshift.org/aws-efs   10s



```

Create a PVC with the sc `aws-efs` and a pod to use the PVC: Note that [efs supports RWX](https://github.com/kubernetes-incubator/external-storage/blob/master/aws/efs/deploy/claim.yaml#L8-L9).

```bash
# oc delete project ttt
# oc process -f https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/pvc_template.yaml -p STORAGE_CLASS_NAME=aws-efs -p PVC_NAME=abc | oc create -f -
# oc get pvc
NAME      STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
abc       Bound     pvc-98c1372a-d244-11e8-87bb-0212c16dd3de   3Gi        RWO            aws-efs        28s


# oc create -f https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/dc_centos_with_pv.yaml

# oc get pod
NAME             READY     STATUS    RESTARTS   AGE
centos-1-hrbrw   1/1       Running   0          19s
# oc rsh centos-1-hrbrw
sh-4.2$ df -hT | grep efs
fs-2a886d82.efs.us-west-2.amazonaws.com:/data/persistentvolumes/abc-pvc-98c1372a-d244-11e8-87bb-0212c16dd3de nfs4     8.0E     0  8.0E   0% /bbb

```


Uninstall:

```bash
# ansible-playbook -v -i /tmp/2.file /root/openshift-ansible/playbooks/openshift-provisioners/config.yml -e openshift_provisioners_install_provisioners=False
```

## CSI

Pre-installation:
```bash
# yum install -y ansible python-virtualenv

```

[Installation](https://github.com/gluster/gcs):

```bash
# git clone https://github.com/gluster/gcs.git
# cd gcs/
### modify ./deploy/prepare.sh: remove the vagrant checking and the path ./deploy/prepare.sh
# ./deploy/prepare.sh
# source gcs-venv/bin/activate

# cd deploy/
# vi ~/aaa/gcs.yml
master ansible_host=ip-172-31-43-164.us-west-2.compute.internal

gcs1 ansible_host=ip-172-31-47-15.us-west-2.compute.internal gcs_disks='["/dev/nvme2n1"]'
gcs2 ansible_host=ip-172-31-59-125.us-west-2.compute.internal gcs_disks='["/dev/nvme2n1"]'
gcs3 ansible_host=ip-172-31-60-208.us-west-2.compute.internal gcs_disks='["/dev/nvme2n1"]'

[kube-master]
master

[gcs-node]
gcs1
gcs2
gcs3

# ansible-playbook -i ~/aaa/gcs.yml deploy-gcs.yml

# 

```

Blocked by [gcs/issues/46](https://github.com/gluster/gcs/issues/46).

## Volume Snapshot

## Operators for storage
