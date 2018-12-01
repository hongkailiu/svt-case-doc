# CNS with pre-release images

20180430: Those pre-release images are [synced to aws-reg](https://bugzilla.redhat.com/show_bug.cgi?id=1554385).

## AtomicHost@OpenStack

Login <code>QEOS10 OpenStack</code> and launch an instance based on image
<code>rhel-atomic-cloud-7.3.4-8</code>. The reason we chose that image here
is that docker is pre-installed. In order to establish ssh to the machine, we
need to assign a floating IP to it.

## Check out images version (RH internal network)


```sh
# curl -L -o jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
# chmod +x jq
# #rhgs3/rhgs-server-rhel7
# curl -s -k brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888/v1/repositories/rhgs3/rhgs-server-rhel7/tags | ./jq 'keys' | ./jq -r .[] | sort -V | grep latest -B1
3.3.0-19
latest

# #rhgs3/rhgs-volmanager-rhel7
# curl -s -k brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888/v1/repositories/rhgs3/rhgs-volmanager-rhel7/tags | ./jq 'keys' | ./jq -r .[] | sort -V | grep latest -B1
3.3.0-12
latest

curl -s -k brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888/v1/repositories/rhgs3/rhgs-gluster-block-prov-rhel7/tags | ./jq 'keys' | ./jq -r .[] | sort -V | grep latest -B1
3.3.1-3
latest

```

## Save/load images

```sh
# vi /etc/docker/daemon.json
{
  "insecure-registries" : ["brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888"]
}

# systemctl restart docker
# docker pull brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888/rhgs3/rhgs-server-rhel7:3.3.0-19
# docker pull brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888/rhgs3/rhgs-volmanager-rhel7:3.3.0-12


# docker save --output rhgs-server-rhel7.tar brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888/rhgs3/rhgs-server-rhel7:3.3.0-19
# docker save --output rhgs-volmanager-rhel7.tar brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888/rhgs3/rhgs-volmanager-rhel7:3.3.0-12
# ls *.tar
rhgs-server-rhel7.tar  rhgs-volmanager-rhel7.tar
```

Then <code>scp</code> those two tar files to the <code>glusterfs</code> nodes.
On _each_ of them:

```sh
# docker load --input rhgs-server-rhel7.tar
# docker load --input rhgs-volmanager-rhel7.tar
# docker images | grep rhgs3
brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888/rhgs3/rhgs-volmanager-rhel7   3.3.0-12             3d13e1900590        2 weeks ago         425 MB
brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888/rhgs3/rhgs-server-rhel7       3.3.0-19             b99244967506        4 weeks ago         405.9 MB

```


## Install
Run the playbook to configure the cluster as described in [glusterFD.md](glusterFD.md)
with the following change in the inventory file:

```sh
...
glusterfs_devices=["/dev/xvdf"]
...
openshift_storage_glusterfs_image=brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888/rhgs3/rhgs-server-rhel7
openshift_storage_glusterfs_version=3.3.0-12
openshift_storage_glusterfs_heketi_image=brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888/rhgs3/rhgs-volmanager-rhel7
openshift_storage_glusterfs_heketi_version=3.3.0-9
...

```

## Check
Check images:

```sh
# oc get pods -n glusterfs -o yaml | grep "image"
```
