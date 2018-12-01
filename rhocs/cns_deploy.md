# CNS tool: cns-deploy

Use cns-deploy to deploy CNS on OCP. 

* Follow the doc [here](https://access.redhat.com/documentation/en-us/red_hat_gluster_storage/3.3/html-single/container-native_storage_for_openshift_container_platform/#chap-Documentation-Red_Hat_Gluster_Storage_Container_Native_with_OpenShift_Platform-Setting_the_environment-Deploy_CNS).
* Previous version of the doc is [here](https://access.redhat.com/documentation/en-us/red_hat_gluster_storage/3.1/html/container-native_storage_for_openshift_container_platform_3.4/ch04s02).
* [Keith Tenzer's blog](https://keithtenzer.com/2017/03/29/storage-for-containers-using-container-native-storage-part-iii/).

## Installation

### Install OpenShift cluster based on rhel AMIs
1 master, 1 infra, 3 compute nodes.

## Install the pkgs

Checking the package version (Oct 31, 2017)

```sh
# yum info cns-deploy heketi-client
Loaded plugins: amazon-id, rhui-lb, search-disabled-repos
Available Packages
Name        : cns-deploy
Version     : 3.1.0
...
Name        : heketi-client
Version     : 4.0.0
```

Checking on brew: [cns-deploy](https://brewweb.engineering.redhat.com/brew/packageinfo?packageID=61728) and [heketi-*]( https://brewweb.engineering.redhat.com/brew/packageinfo?packageID=54317)

```
cns-deploy-5.0.0-54.el7rhgs
heketi-5.0.0-16.el7rhgs
```

Get latest packages and scp to master:

```sh
# pwd
/root/local_rpm_repo

# ll
total 11660
-rw-r--r--. 1 root root   32460 Oct 31 18:30 cns-deploy-5.0.0-54.el7rhgs.x86_64.rpm
-rw-r--r--. 1 root root 6311420 Oct 31 18:30 heketi-5.0.0-16.el7rhgs.x86_64.rpm
-rw-r--r--. 1 root root 5567652 Oct 31 18:30 heketi-client-5.0.0-16.el7rhgs.x86_64.rpm
-rw-r--r--. 1 root root   23708 Oct 31 18:30 python-heketi-5.0.0-16.el7rhgs.x86_64.rpm
```

Config this folder as a local yum repo. See the steps in [docker_version.md](../fix/docker_version.md).

```sh
# yum install -y cns-deploy heketi-client
```

Check images in templates:

```sh
# grep -ri rhgs /usr/share/heketi/templates/*
/usr/share/heketi/templates/deploy-heketi-template.yaml:          image: rhgs3/rhgs-volmanager-rhel7:3.3.0-362
/usr/share/heketi/templates/glusterblock-provisioner.yaml:          image: rhgs3/rhgs-gluster-block-prov-rhel7:3.3.0-362
/usr/share/heketi/templates/glusterfs-template.yaml:        - image: rhgs3/rhgs-server-rhel7:3.3.0-362
/usr/share/heketi/templates/gluster-s3-template.yaml:          image: rhgs3/rhgs-s3-server-rhel7:3.3.0-362
/usr/share/heketi/templates/heketi-template.yaml:          image: rhgs3/rhgs-volmanager-rhel7:3.3.0-362
```

Those images have been released already on [access](https://access.redhat.com/containers/#/search/rhgs3). See more informatin on [gluster block](https://github.com/gluster/gluster-block).

Then we can run a [playbook](../playbooks#prepare-cns-deploy-tool) to prepare cns-tool with inventory like this:

```
[masters]
ec2-54-218-80-58.us-west-2.compute.amazonaws.com ansible_user=root ansible_ssh_private_key_file="/home/hongkliu/.ssh/id_rsa_perf"

[others]
ec2-54-186-95-29.us-west-2.compute.amazonaws.com ansible_user=root ansible_ssh_private_key_file="/home/hongkliu/.ssh/id_rsa_perf"

[glusterfs]
ec2-54-191-66-43.us-west-2.compute.amazonaws.com ansible_user=root ansible_ssh_private_key_file="/home/hongkliu/.ssh/id_rsa_perf"
ec2-54-218-60-199.us-west-2.compute.amazonaws.com ansible_user=root ansible_ssh_private_key_file="/home/hongkliu/.ssh/id_rsa_perf"
ec2-34-223-226-135.us-west-2.compute.amazonaws.com ansible_user=root ansible_ssh_private_key_file="/home/hongkliu/.ssh/id_rsa_perf"
```

```sh
$ ansible-playbook -i inv.file playbooks/cns_deploy.yml
```

Run cns-deploy (on master):

```sh
# oc new-project storage-project
###This command looks odd but it is in the official doc: 
###https://access.redhat.com/documentation/en-us/red_hat_gluster_storage/3.3/html-single/container-native_storage_for_openshift_container_platform/#chap-Documentation-Red_Hat_Gluster_Storage_Container_Native_with_OpenShift_Platform-Setting_the_environment-Preparing_RHOE
# oadm policy add-scc-to-user privileged -z storage-project
###The following commamnd has to be executed once, otherwise pods for ds of glusterfs cannot be created.
# oadm policy add-scc-to-user privileged -z default
# # More info on --block-host: http://post-office.corp.redhat.com/archives/rhs-containers/2017-September/msg00013.html
# cns-deploy -n storage-project -g topology.json -y --block-host 60
...
Deployment complete!

#  oc get pod -n storage-project
NAME                                  READY     STATUS    RESTARTS   AGE
glusterblock-provisioner-dc-1-hb9w2   1/1       Running   0          4m
glusterfs-j9qjp                       1/1       Running   0          6m
glusterfs-ld7nk                       1/1       Running   0          6m
glusterfs-whgvk                       1/1       Running   0          6m
heketi-1-nzvps                        1/1       Running   0          4m
```

Notice that there is new block provisioner pod <code>glusterblock-provisioner-dc-1-hb9w2</code>.

Create storage class for block volumes:

```sh
# oc get route -n storage-project 
NAME      HOST/PORT                                             PATH      SERVICES   PORT      TERMINATION   WILDCARD
heketi    heketi-storage-project.apps.1031-hye.qe.rhcloud.com             heketi     <all>                   None

# vi sc_glusterblock.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: glusterblock
provisioner: gluster.org/glusterblock
parameters:
  resturl: "http://heketi-storage-project.apps.1031-hye.qe.rhcloud.com"
  restuser: "admin"
  opmode: "heketi"
  hacount: "2"
  restauthenabled: "false"

# oc create -f sc_glusterblock.yaml

### Create PVC
# oc new-project aaa
# oc create -f https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/pvc_glusterblock.yaml
# oc get pvc
NAME          STATUS    VOLUME                                     CAPACITY   ACCESSMODES   STORAGECLASS   AGE
pvc-gluster   Bound     pvc-bbebdc99-bf18-11e7-8d96-0201cedc5658   1Gi        RWO           glusterblock   5m

```


## Clean-up before reinstallation

```sh
# oc label node ip-172-31-60-68.us-west-2.compute.internal storagenode-
# oc label node ip-172-31-25-158.us-west-2.compute.internal storagenode-
# oc label node ip-172-31-25-106.us-west-2.compute.internal storagenode-
# oc delete project storage-project
### on each glusfterfs node
# rm -rf /var/lib/heketi/
# pvdisplay /dev/xvdf
  /run/lvm/lvmetad.socket: connect failed: Connection refused
  WARNING: Failed to connect to lvmetad. Falling back to device scanning.
  --- Physical volume ---
  PV Name               /dev/xvdf
  VG Name               vg_d92f9db886930808a186305565e5e62c
  PV Size               200.00 GiB / not usable 132.00 MiB
  Allocatable           yes 
  PE Size               4.00 MiB
  Total PE              51167
  Free PE               50649
  Allocated PE          518
  PV UUID               6GkVH4-5Hm0-B7WR-HEEf-UZTG-2lYx-c4fpN0
   
# vgs
  /run/lvm/lvmetad.socket: connect failed: Connection refused
  WARNING: Failed to connect to lvmetad. Falling back to device scanning.
  VG                                  #PV #LV #SN Attr   VSize   VFree   
  docker_vg                             1   1   0 wz--n- <50.00g       0 
  vg_d92f9db886930808a186305565e5e62c   1   2   0 wz--n- 199.87g <197.85g

# vgremove -f vg_d92f9db886930808a186305565e5e62c
  /run/lvm/lvmetad.socket: connect failed: Connection refused
  WARNING: Failed to connect to lvmetad. Falling back to device scanning.
  Logical volume "brick_eb8300e8a01d091b40ebb601004de22b" successfully removed
  Logical volume "tp_eb8300e8a01d091b40ebb601004de22b" successfully removed
Volume group "vg_d92f9db886930808a186305565e5e62c" successfully removed

###OPTIONAL:B###
# pvremove /dev/xvdf
  /run/lvm/lvmetad.socket: connect failed: Connection refused
  WARNING: Failed to connect to lvmetad. Falling back to device scanning.
  Labels on physical volume "/dev/xvdf" successfully wiped.

# pvcreate -ff /dev/xvdf
###OPTIONAL:E###

# lsblk 
NAME                           MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
xvda                           202:0    0   10G  0 disk 
├─xvda1                        202:1    0    1M  0 part 
└─xvda2                        202:2    0   10G  0 part /
xvdb                           202:16   0   60G  0 disk 
└─xvdb1                        202:17   0   50G  0 part 
  └─docker_vg-docker--root--lv 253:0    0   50G  0 lvm  /var/lib/docker
xvdf                           202:80   0  200G  0 disk 

```



