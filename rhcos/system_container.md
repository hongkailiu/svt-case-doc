# System Container

## Doc

* [system-container@os](https://docs.openshift.com/container-platform/latest/install_config/install/advanced_install.html#advanced-install-configuring-system-containers)
* [system-container@access](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux_atomic_host/7/html/managing_containers/running_system_containers)
* [system-container@atomic-blog](http://www.projectatomic.io/blog/2016/09/intro-to-system-containers/)

## Existing system containers

* [etcd, flannel, and others](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux_atomic_host/7/html/managing_containers/running_system_containers)
* [master, node, etcd, openvswitch, docker, cri-o](https://github.com/openshift/openshift-ansible/blob/master/inventory/byo/hosts.ose.example#L50)


## Openshift and system container

Using flexy to install openshift cluster on Atomic Host using system containers: [Here](https://github.com/hongkailiu/svt-case-doc/blob/master/learn/flexy.md#atomic-host).

Check the system container:

```sh
# #docker does not even know system containers
# docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
 

# atomic containers list --no-trunc 
   CONTAINER ID                        IMAGE                                                    COMMAND                                    CREATED          STATE      BACKEND    RUNTIME   
   etcd                                registry.access.redhat.com/rhel7/etcd                    /usr/bin/etcd-env.sh /usr/bin/etcd         2017-09-28 12:35 running    ostree     runc      
   atomic-openshift-master-api         registry.ops.openshift.com/openshift3/ose:v3.7.0         /usr/local/bin/system-container-wrapper.sh 2017-09-28 12:44 running    ostree     runc      
   atomic-openshift-master-controllers registry.ops.openshift.com/openshift3/ose:v3.7.0         /usr/local/bin/system-container-wrapper.sh 2017-09-28 12:44 running    ostree     runc      
   atomic-openshift-node               registry.ops.openshift.com/openshift3/node:v3.7.0        /usr/local/bin/system-container-wrapper.sh 2017-09-28 12:51 running    ostree     runc      
   openvswitch                         registry.ops.openshift.com/openshift3/openvswitch:v3.7.0 /usr/local/bin/system-container-wrapper.sh 2017-09-28 12:51 running    ostree     runc
```

We can see that openshift/k8s chooses openvswitch as [network plugin](https://kubernetes.io/docs/getting-started-guides/scratch/#network), instead of flannel.

## Logging

We can see that node, master-api, and master-controllers run as system containers and no counterpart of <code>docker logs</code> has been found yet. But those containers are still under <code>systemd</code>.

```sh
# #all messages
# journalctl -f
# #by unit
# journalctl -u atomic-openshift-node -f

```

Pod log

docker log-driver: journald/json-file

```sh
tail -f /var/log/pods/66083e1f-b368-11e7-ac9e-023e42ffd7a8/heketi_0.log
```

## Useful links

1. [blog on ostree](https://samthursfield.wordpress.com/2014/01/16/the-fundamentals-of-ostree/)
