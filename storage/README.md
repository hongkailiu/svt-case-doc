# Storage

## loop[back] device
https://en.wikipedia.org/wiki/Loop_device
https://www.thegeekdiary.com/how-to-create-virtual-block-device-loop-device-filesystem-in-linux/
http://tldp.org/HOWTO/Cryptoloop-HOWTO/loopdevice-setup.html

## Block device

* [block-device@wiki](https://en.wikipedia.org/wiki/Device_file#Block_devices)

## Object storage

## File System

check fs

```sh
$ df -T
```

## LVM

## [Storage commands on RHEL](https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Deployment_Guide/s1-sysinfo-filesystems.html)

List block devices with [lsblk](https://linux.die.net/man/8/lsblk):

```sh
$ lsblk
NAME                                          MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINT
sda                                             8:0    0   477G  0 disk
├─sda1                                          8:1    0     3G  0 part  /boot
└─sda2                                          8:2    0 235.5G  0 part
  └─luks-64db41f8-4cc4-4b1b-80da-543423b948c5 253:0    0 235.5G  0 crypt
    ├─RHEL7CSB-Root                           253:1    0    30G  0 lvm   /
    ├─RHEL7CSB-Home                           253:2    0   100G  0 lvm   /home
    └─RHEL7CSB-Swap                           253:3    0     8G  0 lvm   [SWAP]

# lsblk
NAME                             MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
xvda                             202:0    0  10G  0 disk
├─xvda1                          202:1    0   1M  0 part
└─xvda2                          202:2    0  10G  0 part /
xvdb                             202:16   0  30G  0 disk
└─xvdb1                          202:17   0  30G  0 part
  ├─docker_vg-docker--pool_tmeta 253:0    0  32M  0 lvm
  │ └─docker_vg-docker--pool     253:2    0  30G  0 lvm
  └─docker_vg-docker--pool_tdata 253:1    0  30G  0 lvm
    └─docker_vg-docker--pool     253:2    0  30G  0 lvm
```

## Container storage

[Daniel Messer's blog](https://keithtenzer.com/2017/03/24/storage-for-containers-using-gluster-part-ii/)
