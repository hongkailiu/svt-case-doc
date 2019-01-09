

# Drain Node Test
Cluster:

| role  |  number  |
|---|---|
| lb (master) | 1 |
| master-etcd   |  2 |
| infra  | 1  |
| computing-nodes  | 2  |

## limits from the cloud provides

* aws ec2: [52 for m4 instances](https://bugzilla.redhat.com/show_bug.cgi?id=1490989), [25 for m5 instances](https://github.com/kubernetes/kubernetes/issues/59015)
* gc2: [63](https://cloud.google.com/compute/docs/disks/)

## Config master

```sh
# vi /etc/sysconfig/atomic-openshift-master
...
KUBE_MAX_PD_VOLS=260
# systemctl daemon-reload
# systemctl restart atomic-openshift-master.service
# #or if the cluster is HA, do this on all masters:
# vi /etc/sysconfig/atomic-openshift-master-controllers
...
KUBE_MAX_PD_VOLS=260
# systemctl daemon-reload
# systemctl restart atomic-openshift-master-controllers.service
#
```

OCP 3.10:

```sh
# vi /tmp/controller.yaml
   image: registry.reg-aws.openshift.com:443/openshift3/ose-control-plane:v3.10
   env:
   - name: KUBE_MAX_PD_VOLS
     value: "60" 

```

## Run test

Move _reg-console_ pod to infra-node.

```sh
# oc patch -n default deploymentconfigs/registry-console --patch '{"spec": {"template": {"spec": {"nodeSelector": {"region": "infra"}}}}}'
```

```sh
# oc scale --replicas=0 -n openshift-ansible-service-broker deploymentconfigs/asb-etcd
# oc delete pvc -n openshift-ansible-service-broker etcd
# oc scale --replicas=0 -n openshift-ansible-service-broker deploymentconfigs/asb
```

Disable one of the computing node <code>node2</code>.

```sh
# oc adm manage-node $node2_name --schedulable=false
```

Create pods with PVCs. 1 project, 249 templates:

```sh
# cd svt/openshift_scalability
# curl -o ./content/fio/fio-template1.json https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/fio-template1.json
# vi content/fio/fio-parameters.yaml
...
        file: ./content/fio/fio-template1.json
        parameters:
          - STORAGE_CLASS: "gp2" # this is name of storage class to use
          - STORAGE_SIZE: "1Gi" # this is size of PVC mounted inside pod
          - MOUNT_PATH: "/mnt/pvcmount"
          - DOCKER_IMAGE: "gcr.io/google_containers/pause-amd64:3.0"
...

# python -u cluster-loader.py -v -f content/fio/fio-parameters.yaml
```

Enable the disabled computing node <code>node2</code>.

```sh
# oc adm manage-node $node2_name --schedulable=true
```

Drain node <code>node1</code>.

```sh
# oc adm drain $node1_name
```

## ocp 4.0

Config `KUBE_MAX_PD_VOLS`: TODO

If there are more than 2 compute nodes, or default node selector is not set, then
* choose 2 compute nodes and then label them with `aaa=bbb`
* use `fio-template2.json` instead of `fio-template1.json` where 

  ```
  $ diff fio-template1.json fio-template2.json 
  53a54,56
  >                     "nodeSelector": {
  > 			"aaa": "bbb"
  > 		},

  ```

