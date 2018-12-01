# Gluster: Brick Multiplexing

## Doc

* [release note 3.10.0](https://gluster.readthedocs.io/en/latest/release-notes/3.10.0/)
* [mojo](https://mojo.redhat.com/docs/DOC-1138715)

## Enable brick multiplexing

### [Checking gluster version](https://stackoverflow.com/questions/41626467/how-to-display-the-version-of-glusterfs)

```sh
# oc project glusterfs
# oc get pods
NAME                      READY     STATUS    RESTARTS   AGE
glusterfs-storage-90mfq   1/1       Running   0          18m
glusterfs-storage-h8plb   1/1       Running   0          18m
glusterfs-storage-r4crw   1/1       Running   0          18m
heketi-storage-1-4b9gp    1/1       Running   0          15m

# oc rsh glusterfs-storage-h8plb

sh-4.2# glusterfs --version
glusterfs 3.8.4 built on May 30 2017 10:17:50
...

sh-4.2# gluster volume set all cluster.brick-multiplex on
volume set: failed: option : cluster.brick-multiplex does not exist
Did you mean cluster.tier-max-files?

```

So we need to use pre-released images. Follow steps [here](cns_internal.md).

```sh
# docker pull brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888/rhgs3/rhgs-server-rhel7:3.3.0-12
# docker save --output rhgs-server-rhel7.tar brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888/rhgs3/rhgs-server-rhel7:3.3.0-12
# docker pull brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888/rhgs3/rhgs-volmanager-rhel7:3.3.0-9
# docker save --output rhgs-volmanager-rhel7.tar brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888/rhgs3/rhgs-volmanager-rhel7:3.3.0-9
```

```sh
sh-4.2# glusterfs --version
glusterfs 3.8.4 built on Aug 11 2017 08:58:58
...

# #check if brick-multiplex is supported
sh-4.2# gluster volume set help | grep cluster.brick-multiplex
Option: cluster.brick-multiplex

sh-4.2# gluster volume set all cluster.brick-multiplex on
Brick-multiplexing is supported only for container workloads (CNS/CRS). Also it is advised to make sure that either all volumes are in stopped state or no bricks are running before this option is modified.Do you still want to continue? (y/n) y
volume set: success

sh-4.2# gluster volume get all cluster.brick-multiplex
Option                                  Value
------                                  -----
cluster.brick-multiplex                 on

# #rsh to other glusterfs pods, check the above command. Should be on as well.
```

So multiplexing is supported on this version <code>glusterfs 3.8.4</code> too.
