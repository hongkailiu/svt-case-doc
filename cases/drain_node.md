

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

```
$ oc get node | grep worker
ip-10-0-132-122.us-east-2.compute.internal   Ready     worker    2h        v1.11.0+406fc897d8
ip-10-0-146-194.us-east-2.compute.internal   Ready     worker    2h        v1.11.0+406fc897d8
ip-10-0-164-234.us-east-2.compute.internal   Ready     worker    2h        v1.11.0+406fc897d8

$ export NODE_1=ip-10-0-132-122.us-east-2.compute.internal
$ export NODE_2=ip-10-0-146-194.us-east-2.compute.internal

$ oc label node ${NODE_1} aaa=bbb
$ oc label node ${NODE_2} aaa=bbb
```

Problem 1: `error: pods with local storage`

```
$ oc adm drain ${NODE_1} --ignore-daemonsets
node/ip-10-0-132-122.us-east-2.compute.internal already cordoned
error: unable to drain node "ip-10-0-132-122.us-east-2.compute.internal", aborting command...

There are pending nodes to be drained:
 ip-10-0-132-122.us-east-2.compute.internal
error: pods with local storage (use --delete-local-data to override): alertmanager-main-1, grafana-58456d859d-q2cdh, prometheus-k8s-0

$ oc get pod -n fioatest0 --show-labels
NAME          READY     STATUS    RESTARTS   AGE       LABELS
fio-0-snddl   1/1       Running   0          31m       run=fio,test=fio
(svtenv) [fedora@ip-172-31-32-37 openshift_scalability]$ oc adm drain ${NODE_1} --ignore-daemonsets --pod-selector='test=fio'
node/ip-10-0-132-122.us-east-2.compute.internal already cordoned
pod/fio-0-snddl evicted

```

Problem 2: `1 node(s) had no available volume zone`

```
$ oc get pod
NAME          READY     STATUS    RESTARTS   AGE
fio-0-2tgx5   0/1       Pending   0          16m

$ oc describe pod fio-0-2tgx5
...
Events:
...
  Warning  FailedScheduling  1m (x602 over 16m)  default-scheduler  0/6 nodes are available: 1 node(s) had no available volume zone, 1 node(s) were unschedulable, 4 node(s) didn't match node selector.

$ oc describe node ${NODE_1} | grep ProviderID
ProviderID:                               aws:///us-east-2a/i-05058c0a174142b1e
$ oc describe node ${NODE_2} | grep ProviderID
ProviderID:                               aws:///us-east-2b/i-0f2440cccfc16deb3


```

Probably we cannot do this because we cannot move ebs PV from an instance in `us-east-2a` to another instance in `us-east-2b`.

Update on 20190124: Create 4 workers

```
$ oc get machines -n openshift-cluster-api  
NAME                                 INSTANCE              STATE     TYPE        REGION      ZONE         AGE
hongkliu19-master-0                  i-0414d68a548f98c76   running   m5.xlarge   us-east-2   us-east-2a   5h
hongkliu19-master-1                  i-0c44213340309e025   running   m5.xlarge   us-east-2   us-east-2b   5h
hongkliu19-master-2                  i-089851f1f00be7d06   running   m5.xlarge   us-east-2   us-east-2c   5h
hongkliu19-worker-us-east-2a-c8kj7   i-09e386cb1e4b6a698   running   m5.xlarge   us-east-2   us-east-2a   5h
hongkliu19-worker-us-east-2a-nfncf   i-05167a2283dbb423f   running   m5.xlarge   us-east-2   us-east-2a   5h
hongkliu19-worker-us-east-2b-xzxp5   i-0fef07730257e6199   running   m5.xlarge   us-east-2   us-east-2b   5h
hongkliu19-worker-us-east-2c-lnggj   i-0fbd1e08ac70e1bb2   running   m5.xlarge   us-east-2   us-east-2c   5h
```

So `hongkliu19-worker-us-east-2a-c8kj7` and `hongkliu19-worker-us-east-2a-nfncf` are in the same zone `us-east-2a`.

```
$ oc get machines -n openshift-cluster-api hongkliu19-worker-us-east-2a-c8kj7 -o yaml | grep address | grep ip
  - address: ip-10-0-131-229.us-east-2.compute.internal
$ oc get machines -n openshift-cluster-api hongkliu19-worker-us-east-2a-nfncf -o yaml | grep address | grep ip
  - address: ip-10-0-141-124.us-east-2.compute.internal
```

Label those 2 nodes as above.

New problem: the PV can be created in a zone which is not `us-east-2a`, and then the pod is stuck in `Pending` forever.

