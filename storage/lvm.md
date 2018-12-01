# LVM

## Doc

* [lvm commands](https://www.tecmint.com/create-lvm-storage-in-linux/)
* [replace resize2fs with xfs_growfs](https://stackoverflow.com/questions/26305376/resize2fs-bad-magic-number-in-super-block-while-trying-to-open)


## Extend LVM with Atomic Host on EC2 instance

We could use gold AMI for (Red Hat) Atomic Host and I would nicely done the LVM partition. We use Fedora Atomic Host AMI here for training of LVMs.

Launch ec2 instance without specifying the size of root device:

```sh
# lsblk
NAME                          MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
xvda                          202:0    0    6G  0 disk
├─xvda1                       202:1    0  300M  0 part /boot
└─xvda2                       202:2    0  5.7G  0 part
  ├─atomicos-root             253:0    0    3G  0 lvm  /sysroot
  └─atomicos-docker--root--lv 253:1    0  1.1G  0 lvm  /sysroot/ostree/deploy/fedora-atomic/var/lib/docker
```

It is so small and the reason is mentioned [here](http://www.projectatomic.io/docs/docker-storage-recommendation/).
Let us get a 60g device:

```sh
(awsenv) [hongkliu@hongkliu awscli]$ aws ec2 run-instances --image-id ami-b11febc9 \
     --security-group-ids sg-5c5ace38 --count 1 --instance-type m4.large --key-name id_rsa_perf \
     --subnet subnet-4879292d --block-device-mappings "[{\"DeviceName\":\"/dev/sda1\", \"Ebs\":{\"VolumeSize\": 60}}]" \
     --query 'Instances[*].InstanceId' \
     --tag-specifications="[{\"ResourceType\":\"instance\",\"Tags\":[{\"Key\":\"Name\",\"Value\":\"qe-hongkliu-atomic-test\"}]}]"

```

Check the size:

```sh
[fedora@ip-172-31-10-230 ~]$ lsblk
NAME                          MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
xvda                          202:0    0   60G  0 disk
├─xvda1                       202:1    0  300M  0 part /boot
└─xvda2                       202:2    0 59.7G  0 part
  ├─atomicos-root             253:0    0    3G  0 lvm  /sysroot
  └─atomicos-docker--root--lv 253:1    0 22.7G  0 lvm  /sysroot/ostree/deploy/fedora-atomic/var/lib/docker

[fedora@ip-172-31-10-230 ~]$ sudo -i
[root@ip-172-31-10-230 ~]# pvs
  PV         VG       Fmt  Attr PSize  PFree
  /dev/xvda2 atomicos lvm2 a--  59.70g 34.07g

[root@ip-172-31-10-230 ~]# lvdisplay
  --- Logical volume ---
  LV Path                /dev/atomicos/root
  LV Name                root
  VG Name                atomicos
  LV UUID                otwt7s-Zia5-qler-e8U2-2MtN-BX1e-XCkQVb
  LV Write Access        read/write
  LV Creation host, time localhost.localdomain, 2017-09-05 09:21:55 +0000
  LV Status              available
  # open                 1
  LV Size                2.93 GiB
  Current LE             750
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:0

  --- Logical volume ---
  LV Path                /dev/atomicos/docker-root-lv
  LV Name                docker-root-lv
  VG Name                atomicos
  LV UUID                Az7uX4-8TgE-cc38-4BkR-irM1-Faj6-BRUPPy
  LV Write Access        read/write
  LV Creation host, time ip-172-31-10-230.us-west-2.compute.internal, 2017-09-18 19:58:56 +0000
  LV Status              available
  # open                 1
  LV Size                22.71 GiB
  Current LE             5813
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:1

[root@ip-172-31-10-230 ~]# vgdisplay
  --- Volume group ---
  VG Name               atomicos
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  4
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                2
  Open LV               2
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               59.70 GiB
  PE Size               4.00 MiB
  Total PE              15284
  Alloc PE / Size       6563 / 25.64 GiB
  Free  PE / Size       8721 / 34.07 GiB
  VG UUID               FLImoM-nkRg-hQBb-D9hB-8mqf-PHgI-7jX5S1
```

We get 3g of root and 22.7g of docker. Not very desirable, huh?

By [default](http://www.projectatomic.io/docs/docker-storage-recommendation/),
docker use 40% of free space. (59.7-3)*0.4=22.68. So 22.7 is correct.

So let us extend both of LVMs:

```sh
[root@ip-172-31-10-230 ~]# lvextend -l +3000 /dev/atomicos/root
  Size of logical volume atomicos/root changed from 2.93 GiB (750 extents) to 14.65 GiB (3750 extents).
  Logical volume atomicos/root successfully resized.

[root@ip-172-31-10-230 ~]# xfs_growfs /dev/atomicos/root
meta-data=/dev/mapper/atomicos-root isize=512    agcount=4, agsize=192000 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=1 spinodes=0 rmapbt=0
         =                       reflink=0
data     =                       bsize=4096   blocks=768000, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal               bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
data blocks changed from 768000 to 3840000

[root@ip-172-31-10-230 ~]# vgdisplay
  --- Volume group ---
  VG Name               atomicos
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  5
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                2
  Open LV               2
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               59.70 GiB
  PE Size               4.00 MiB
  Total PE              15284
  Alloc PE / Size       9563 / 37.36 GiB
  Free  PE / Size       5721 / 22.35 GiB
  VG UUID               FLImoM-nkRg-hQBb-D9hB-8mqf-PHgI-7jX5S1

[root@ip-172-31-10-230 ~]# lvextend -l +5721 /dev/atomicos/docker-root-lv
  Size of logical volume atomicos/docker-root-lv changed from 22.71 GiB (5813 extents) to 45.05 GiB (11534 extents).
  Logical volume atomicos/docker-root-lv successfully resized.
[root@ip-172-31-10-230 ~]# xfs_growfs /dev/atomicos/docker-root-lv
meta-data=/dev/mapper/atomicos-docker--root--lv isize=512    agcount=4, agsize=1488128 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=1 spinodes=0 rmapbt=0
         =                       reflink=0
data     =                       bsize=4096   blocks=5952512, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal               bsize=4096   blocks=2906, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
data blocks changed from 5952512 to 11810816

[root@ip-172-31-10-230 ~]# vgdisplay
  --- Volume group ---
  VG Name               atomicos
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  6
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                2
  Open LV               2
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               59.70 GiB
  PE Size               4.00 MiB
  Total PE              15284
  Alloc PE / Size       15284 / 59.70 GiB
  Free  PE / Size       0 / 0
  VG UUID               FLImoM-nkRg-hQBb-D9hB-8mqf-PHgI-7jX5S1

[root@ip-172-31-10-230 ~]# lsblk
NAME                          MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
xvda                          202:0    0   60G  0 disk
├─xvda1                       202:1    0  300M  0 part /boot
└─xvda2                       202:2    0 59.7G  0 part
  ├─atomicos-root             253:0    0 14.7G  0 lvm  /sysroot
  └─atomicos-docker--root--lv 253:1    0 45.1G  0 lvm  /sysroot/ostree/deploy/fedora-atomic/var/lib/docker

[root@ip-172-31-10-230 ~]# df -h
Filesystem                             Size  Used Avail Use% Mounted on
devtmpfs                               3.9G     0  3.9G   0% /dev
tmpfs                                  3.9G     0  3.9G   0% /dev/shm
tmpfs                                  3.9G  584K  3.9G   1% /run
tmpfs                                  3.9G     0  3.9G   0% /sys/fs/cgroup
/dev/mapper/atomicos-root               15G  1.5G   14G  10% /sysroot
/dev/xvda1                             283M   76M  188M  29% /boot
/dev/mapper/atomicos-docker--root--lv   46G   79M   45G   1% /var/lib/docker
tmpfs                                  799M     0  799M   0% /run/user/1000
```
