# Test StatefulSets


## Calculation of stress

### online-int

* #computing-node: 4, with limit 30 pods/node. So #pod=120
* #replica: 2 for each SS

So in total we can create 60 SS(s).

_Note_ that there is a [limited](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/volume_limits.html#linux-specific-volume-limits) number (40) of ebs-volumes attached to an ec2-instance.

### Test cluster with Flexy

* #computing-node: 4
* node_instance_type: m4.4xlarge: CPU to support 120 pods 

On test cluster, CPU resources become the bottleneck.

For m5 instances, use 5 compute nodes.

### Vertical stress
1 project and many pods: #proj 1 and #template 60

### Horizontal stress
many project and 1 SS for each project: #proj 60 and #template 1

## Check SC name for PVC

```sh
# oc get storageclass 
NAME            TYPE
ebs (default)   kubernetes.io/aws-ebs 
```

Change the storage class name accordingly in <code>svt/openshift_scalability/content/statefulset-pv-template.json</code>.

## Run
Change the numbers in <code>config/pyconfigStatefulSet.yaml</code> according to the stress and then

```sh
# cd svt/openshift_scalability/
# python -u cluster-loader.py -f config/pyconfigStatefulSet.yaml  -v
```

## Check

```sh
# #pods for each SS should be created in order (reverse order if delete)
# #120 pods should be in Running status
# watch -n 10 "oc get pods --all-namespaces"
# #or watch by oc command
# oc get pods --all-namespaces -w
# #watch pvc
# #120 pvc(s) should be created, each for a pod
# oc get pvc --all-namespaces -w
# #each sever has 2 endpoints to proxy, and #server should be equal to #SS
# oc get endpoints --all-namespaces
NAMESPACE         NAME               ENDPOINTS                                                  AGE
clusterproject0   server0            172.20.0.13:8080,172.20.0.17:8080                          38m
# #you might want to watch events too
# oc get event --all-namespaces -w | grep -v Normal | grep -v FailedScheduling
...
```

Check resources on compute nodes. CPU is the bottleneck:

```sh
$ #Resources allocated on 4 (m4.4xlarge) compute nodes with oc v3.7.0-0.147.1:
$ oc describe node -l region=primary | grep "resources" -A 4
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  CPU Requests	CPU Limits	Memory Requests	Memory Limits
  ------------	----------	---------------	-------------
  15 (93%)	30 (187%)	3840Mi (5%)	7680Mi (11%)
--
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  CPU Requests	CPU Limits	Memory Requests	Memory Limits
  ------------	----------	---------------	-------------
  15 (93%)	30 (187%)	3840Mi (5%)	7680Mi (11%)
--
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  CPU Requests	CPU Limits	Memory Requests	Memory Limits
  ------------	----------	---------------	-------------
  15 (93%)	30 (187%)	3840Mi (5%)	7680Mi (11%)
--
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  CPU Requests	CPU Limits	Memory Requests	Memory Limits
  ------------	----------	---------------	-------------
  15 (93%)	30 (187%)	3840Mi (5%)	7680Mi (11%)

```

## Clean projects
Change according to real number of created projects:

```sh
# for i in {0..2}; do oc delete project "clusterproject$i"; done
```

## OCP 4.0: 20190125

For OCP 4.0 and m5 instances:
Suppose we have n zones in the region of the cluster. Then create m X n workers.

Region `us-east-2` has 3 zones. Then create 6 workers (2 in each zone).

It should support 25 (max_volume) X 6 / 2 = 75 statefulsets.

