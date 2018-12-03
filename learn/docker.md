# Docker

## Default configuration of docker on Fedora 26

Docker installation issue on Fedora 26: [workaround](https://github.com/docker/for-linux/issues/35).

```sh
[fedora@ip-172-31-33-174 ~]$ docker info
Containers: 0
 Running: 0
 Paused: 0
 Stopped: 0
Images: 0
Server Version: 17.09.0-ce-rc2
Storage Driver: overlay2
 Backing Filesystem: extfs
 Supports d_type: true
 Native Overlay Diff: true
Logging Driver: json-file
Cgroup Driver: cgroupfs
Plugins:
 Volume: local
 Network: bridge host macvlan null overlay
 Log: awslogs fluentd gcplogs gelf journald json-file logentries splunk syslog
Swarm: inactive
Runtimes: runc
Default Runtime: runc
Init Binary: docker-init
containerd version: 06b9cb35161009dcb7123345749fef02f7cea8e0
runc version: 3f2f8b84a77f73d38244dd690525642a72156c64
init version: 949e6fa
Security Options:
 seccomp
  Profile: default
Kernel Version: 4.12.13-300.fc26.x86_64
Operating System: Fedora 26 (Cloud Edition)
OSType: linux
Architecture: x86_64
CPUs: 2
Total Memory: 7.793GiB
Name: ip-172-31-33-174.us-west-2.compute.internal
ID: WR52:4N7K:SBMK:JR7E:PMTS:LGNN:QCBB:MN2A:YGGK:MECR:MNOF:ORCT
Docker Root Dir: /var/lib/docker
Debug Mode (client): false
Debug Mode (server): false
Registry: https://index.docker.io/v1/
Experimental: false
Insecure Registries:
 127.0.0.0/8
Live Restore Enabled: false
```

Docker is installed and configured on AMI by [svt/image_provisioner](https://github.com/openshift/svt/tree/master/image_provisioner).

## Logging driver
TODO

## [Storage driver](https://docs.docker.com/engine/userguide/storagedriver/)
When we create EC2 an instance, we always create a volume for docker.
The instance based on AMI will pick that volume up and docker uses it.

### Check current storage driver

```sh
# docker info | grep "Storage Driver" -A13
Storage Driver: devicemapper
 Pool Name: docker_vg-docker--pool
 Pool Blocksize: 524.3 kB
 Base Device Size: 10.74 GB
 Backing Filesystem: xfs
 Data file: 
 Metadata file: 
 Data Space Used: 3.587 GB
 Data Space Total: 12.81 GB
 Data Space Available: 9.227 GB
 Metadata Space Used: 602.1 kB
 Metadata Space Total: 33.55 MB
 Metadata Space Available: 32.95 MB

```

This shows info of space usage of docker on the volumes.

A little reverse engineering on the [lvm](http://www.thegeekstuff.com/2010/08/how-to-create-lvm/):

```sh
# lsblk 
NAME                           MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
...
xvdb                           202:16   0  30G  0 disk 
├─docker_vg-docker--pool_tmeta 253:0    0  32M  0 lvm  
│ └─docker_vg-docker--pool     253:2    0  12G  0 lvm  
└─docker_vg-docker--pool_tdata 253:1    0  12G  0 lvm  
  └─docker_vg-docker--pool     253:2    0  12G  0 lvm  

```

Observations:

* 30G of xvdb: That is the volume we created for docker.
* there are lvm(s) created already: when did it happen?

```sh
root@ip-172-31-44-78: ~ # lvdisplay 
  --- Logical volume ---
  LV Name                docker-pool
  VG Name                docker_vg
  LV UUID                HgAYA5-9kcK-NoPH-v00r-1MVP-XQXB-QPTH4E
  LV Write Access        read/write
  LV Creation host, time ip-172-31-24-168.us-west-2.compute.internal, 2017-08-02 15:58:49 -0400
  LV Pool metadata       docker-pool_tmeta
  LV Pool data           docker-pool_tdata
  LV Status              available
  # open                 0
  LV Size                11.93 GiB
  Allocated pool data    27.99%
  Allocated metadata     1.79%
  Current LE             3055
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           253:2

```

Observations (contd):

* <code>LV Creation host</code> is not even the current host, it must be the host to create AMI.

===

TODO/Question
* Who created that VG _docker_vg_?
* How did docker know which VG to use?

===

_Note_ that only two things different:

* Size of <code>Data Space Available</code>
* Lists of <code>Registry</code> and <code>Insecure Registries</code>

This probably implies that the VG is created in AMI.

### [Overlay2](https://docs.docker.com/engine/userguide/storagedriver/overlayfs-driver/#how-the-overlay2-driver-works)

As default storage driver for <code>docker-ce 17.09.0-ce-rc2</code> and <code>openshift 3.7</code>.

## config files

```bash
$ cat /etc/docker/daemon.json
$ cat /etc/containers/registries.conf 
$ cat /etc/sysconfig/docker

```
