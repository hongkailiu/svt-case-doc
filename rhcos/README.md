# Project Atomic

## Doc

* [project-atomic](http://www.projectatomic.io)
* [atomic@github](https://github.com/projectatomic)
* [flannel](https://github.com/coreos/flannel)

## Launch an instance

AMI provisioner also produces atomic images and we can [launch via aws-cli](https://github.com/hongkailiu/svt-case-doc/blob/master/ec2/ec2.md#atomic-host),
or get AMIs on [fedora.org](https://getfedora.org/en/atomic/download/).



```sh
# #on gold AMI
# cat /etc/*release
NAME="Red Hat Enterprise Linux Atomic Host"
VERSION="7.4.0"
...

# lsblk 
NAME                          MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
xvda                          202:0    0   50G  0 disk 
├─xvda1                       202:1    0  300M  0 part /boot
└─xvda2                       202:2    0 49.7G  0 part 
  ├─atomicos-root             253:0    0 19.8G  0 lvm  /sysroot
  └─atomicos-docker--root--lv 253:1    0   30G  0 lvm  /sysroot/ostree/deploy/rhel-atomic-host/var/lib/docker
```

Follow the [steps](../learn/lvm.md) to extend LVMs if using public Atomic Host AMis.

## Tools
Docker, k8s and etcd are installed out of the box.

```sh
# #on gold AMI
# docker info
...
Server Version: 1.12.6
Storage Driver: overlay2
 Backing Filesystem: xfs
Logging Driver: journald
...

# kubectl --version
Kubernetes v1.5.2

# etcd --version
etcd Version: 3.1.9
Git SHA: 0f4a535
Go Version: go1.8.3
Go OS/Arch: linux/amd64
...

```

## Other tools

```sh
# #runc
[fedora@ip-172-31-25-0 ~]$ runc --version 
runc version spec: 1.0.0

# #atomic
[fedora@ip-172-31-25-0 ~]$ atomic -v
1.18.1

# #skopeo
[fedora@ip-172-31-25-0 ~]$ skopeo -v
skopeo version 0.1.23 commit: 24510500d48f15b52ddfed6972a2a56452ef16b6
```

## Configure K8S
Follow the [steps](http://www.projectatomic.io/docs/gettingstarted/) with the following modification:

* <code>KUBE_ETCD_SERVERS</code> is configured in <code>/etc/kubernetes/apiserver</code> instead of <code>/etc/kubernetes/config</code>:

  ```sh
  # #on public AMI
  [fedora@ip-172-31-25-0 ~]$ sudo vi /etc/kubernetes/apiserver
  # Comma separated list of nodes in the etcd cluster
  KUBE_ETCD_SERVERS="--etcd_servers=http://172.31.25.0:2379"
  ...

  # default admission control policies
  #KUBE_ADMISSION_CONTROL=""
  ```

* <code>KUBE_ADMISSION_CONTROL</code> is disabled up to [issue 33714](https://github.com/kubernetes/kubernetes/issues/33714).
* <code>KUBE_MASTER</code> uses port 8080 instead of 6443:

  ```sh
  [fedora@ip-172-31-25-0 ~]$ sudo vi /etc/kubernetes/config
  ...
  # How the controller-manager, scheduler, and proxy find the apiserver
  KUBE_MASTER="--master=http://172.31.25.0:8080"
  ```

## Debug

Say we need a software for debugging that usually get installed via dnf/yum. Well, we CANNOT do dnf/yum on Atomic Host.

> You don’t install software on Atomic. You build containers on RHEL, CentOS, or Fedora, then run them on Atomic. Sys admin tools are no exception.

Check Jerermy's blog to see how we do it: [rhel-tools](https://developers.redhat.com/blog/2015/03/11/introducing-the-rhel-container-for-rhel-atomic-host/) and [fedora/tools](https://www.projectatomic.io/blog/2015/09/introducing-the-fedora-tools-image-for-fedora-atomic-host/) and

## Tools: TODO

* [atomic](atomic.md)
* [ostree](https://github.com/ostreedev/ostree)
* [runc](https://github.com/opencontainers/runc)
* [skopeo](https://github.com/projectatomic/skopeo)
* [cri-o](cri_o.md)
* [buildah](buildah.md)
