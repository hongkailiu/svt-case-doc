# Node Tuning Operator

## Doc

* [OPENSHIFTQ-12520](https://projects.engineering.redhat.com/browse/OPENSHIFTQ-12520) and [PROD-608](https://jira.coreos.com/browse/PROD-608)
* [sysctls@k8s](https://kubernetes.io/docs/tasks/administer-cluster/sysctl-cluster/)
* [sysctl_params](https://www.kernel.org/doc/Documentation/sysctl/)
* [tuned](https://github.com/redhat-performance/tuned): [rh-doc1](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/power_management_guide/Tuned#sect-tuned-powertop2tuned), [rh-doc2](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/performance_tuning_guide/chap-red_hat_enterprise_linux-performance_tuning_guide-tuned), [tuned@oc](https://docs.openshift.com/container-platform/3.11/scaling_performance/host_practices.html#scaling-performance-capacity-tuned-profile)
* github.repos: [openshift/openshift-tuned](https://github.com/openshift/openshift-tuned), [openshift/cluster-node-tuning-operator](https://github.com/openshift/cluster-node-tuning-operator)

## Background

### sysctl params on linux

* [sysctl params on linux](https://www.kernel.org/doc/Documentation/sysctl/README):

```bash
### to show all sysctl params
# sysctl -a

### those params are store `/proc/sys/`

```

Categories of sysctl params:

* namespaced: _they can be set independently for each pod on a node._
    * safed: `kernel.shm_rmid_forced`, `net.ipv4.tcp_syncookies`. and `net.ipv4.tcp_syncookies`.
        They are enabled by default.
    * unsafed: They are disabled by default. To enable, need to on a node basis by kubelet's args.
* non-namespaced: _Sysctls with no namespace are called node-level sysctls.
    If you need to set them, you must manually configure them on each node’s operating system, or by using a DaemonSet with privileged containers._

[PROD-608](https://jira.coreos.com/browse/PROD-608) focus on `non-namespaced sysctl params`.

### [tuned](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html-single/performance_tuning_guide/index#chap-Red_Hat_Enterprise_Linux-Performance_Tuning_Guide-Tuned)

[Install](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html-single/performance_tuning_guide/index#installation-and-usage):

```bash
#Tested with fedora
# dnf install -y tuned
# systemctl start tuned.service

# tuned-adm list
# tuned-adm active
Current active profile: virtual-guest

# tuned-adm profile <profile>

### pre-defined profles
# ll /usr/lib/tuned

# cat /usr/lib/tuned/virtual-guest/tuned.conf 
#
# tuned configuration
#

[main]
summary=Optimize for running inside a virtual guest
include=throughput-performance

[sysctl]
# If a workload mostly uses anonymous memory and it hits this limit, the entire
# working set is buffered for I/O, and any more write buffering would require
# swapping, so it's time to throttle writes until I/O can catch up.  Workloads
# that mostly use file mappings may be able to use even higher values.
#
# The generator of dirty data starts writeback at this percentage (system default
# is 20%)
vm.dirty_ratio = 30

# Filesystem I/O is usually much more efficient than swapping, so try to keep
# swapping low.  It's usually safe to go even lower than this on systems with
# server-grade storage.
vm.swappiness = 30

### more configurations
# ll /etc/tuned/
total 16
-rw-r--r--. 1 root root   14 Dec 10 13:09 active_profile
-rw-r--r--. 1 root root 1111 Jul  4 15:23 bootcmdline
-rw-r--r--. 1 root root    5 Dec 10 13:09 profile_mode
drwxr-xr-x. 2 root root    6 Jul 15 10:45 recommend.d
-rw-r--r--. 1 root root 1197 Jul  4 15:23 tuned-main.conf

```

### Current solution in Openshift-Ansible

```bash
###on master
# tuned-adm active
Current active profile: openshift-control-plane

# ll /etc/tuned/
total 20
-rw-r--r--. 1 root root   24 Dec 10 15:38 active_profile
-rw-r--r--. 1 root root 1111 Jul  4 19:23 bootcmdline
drwxr-xr-x. 2 root root   24 Dec 10 15:32 openshift
drwxr-xr-x. 2 root root   24 Dec 10 15:32 openshift-control-plane
drwxr-xr-x. 2 root root   24 Dec 10 15:32 openshift-node
-rw-r--r--. 1 root root    5 Dec 10 15:38 profile_mode
-rw-r--r--. 1 root root  290 Dec 10 15:32 recommend.conf
drwxr-xr-x. 2 root root    6 Sep  7 12:56 recommend.d
-rw-r--r--. 1 root root 1197 Sep  7 12:56 tuned-main.conf

```

`openshift` is parent of `openshift-control-plane` (for control plane nodes) and `openshift-node` (for worker nodes).

Those profiles are installed and avtived by [tuned role](https://github.com/openshift/openshift-ansible/tree/master/roles/tuned/) of openshift-ansible.

## Node tuning operator

[We want to maintain the tuned profiles in a pod, instead of a node (servers in OCP cluster)](https://docs.google.com/document/d/1voWLsQBVOQpLHV-coYudIZn1-3NKRJyKDMPuJ53Ei90/edit#).

* [design doc](https://docs.google.com/document/d/1VLH3VD5mzIX-k9B_2tOg72LUEYGiY1Sl6weDUbPpHQQ/edit)
* [POC](https://github.com/jmencak/tuned-containerized/)

### Practicing POC

Tested with OCP 3.11:

* use labels of a node to control the tuned profile
* control sysctl params by editing sysctl parmas in CM

```bash
# git clone https://github.com/jmencak/tuned-containerized
# cd tuned-containerized/

### create objects
# for f in objects/*.yaml ; do oc create -f $f ; done

# oc project tuned
Now using project "tuned" on server "https://ip-172-31-21-230.us-west-2.compute.internal:8443".
# oc get all
NAME              READY     STATUS    RESTARTS   AGE
pod/tuned-2dtkw   1/1       Running   0          48s
pod/tuned-6pr67   1/1       Running   0          48s
pod/tuned-dcc7n   1/1       Running   0          48s

NAME                   DESIRED   CURRENT   READY     UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
daemonset.apps/tuned   3         3         3         3            3           <none>          48s
# oc get cm
NAME              DATA      AGE
tuned-profiles    1         1m
tuned-recommend   1         1m

### check the current setting
# oc get nodes --show-labels
NAME                                          STATUS    ROLES     AGE       VERSION           LABELS
ip-172-31-21-230.us-west-2.compute.internal   Ready     master    22m       v1.11.0+d4cacc0   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=m5.xlarge,beta.kubernetes.io/os=linux,failure-domain.beta.kubernetes.io/region=us-west-2,failure-domain.beta.kubernetes.io/zone=us-west-2b,kubernetes.io/hostname=ip-172-31-21-230.us-west-2.compute.internal,node-role.kubernetes.io/master=true
ip-172-31-37-233.us-west-2.compute.internal   Ready     compute   19m       v1.11.0+d4cacc0   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=m5.xlarge,beta.kubernetes.io/os=linux,failure-domain.beta.kubernetes.io/region=us-west-2,failure-domain.beta.kubernetes.io/zone=us-west-2b,kubernetes.io/hostname=ip-172-31-37-233.us-west-2.compute.internal,node-role.kubernetes.io/compute=true
ip-172-31-48-141.us-west-2.compute.internal   Ready     infra     19m       v1.11.0+d4cacc0   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=m5.xlarge,beta.kubernetes.io/os=linux,failure-domain.beta.kubernetes.io/region=us-west-2,failure-domain.beta.kubernetes.io/zone=us-west-2b,kubernetes.io/hostname=ip-172-31-48-141.us-west-2.compute.internal,node-role.kubernetes.io/infra=true

# oc get pods -o wide
NAME          READY     STATUS    RESTARTS   AGE       IP              NODE                                          NOMINATED NODE
tuned-2dtkw   1/1       Running   0          7m        172.31.21.230   ip-172-31-21-230.us-west-2.compute.internal   <none>
tuned-6pr67   1/1       Running   0          7m        172.31.37.233   ip-172-31-37-233.us-west-2.compute.internal   <none>
tuned-dcc7n   1/1       Running   0          7m        172.31.48.141   ip-172-31-48-141.us-west-2.compute.internal   <none>

# oc logs tuned-2dtkw | grep applied
2018-12-10 19:58:01,757 INFO     tuned.daemon.daemon: static tuning from profile 'openshift-control-plane' applied
# oc logs tuned-6pr67 | grep applied
2018-12-10 19:58:01,627 INFO     tuned.daemon.daemon: static tuning from profile 'openshift-node' applied
# oc logs tuned-dcc7n | grep applied
2018-12-10 19:58:00,955 INFO     tuned.daemon.daemon: static tuning from profile 'openshift-control-plane' applied


### Let's change the label on the worker node, so that an ElasticSearch profile is applied.
# oc label node ip-172-31-37-233.us-west-2.compute.internal node-role.kubernetes.io/elasticsearch=true

# oc logs tuned-6pr67 | grep applied
2018-12-10 19:58:01,627 INFO     tuned.daemon.daemon: static tuning from profile 'openshift-node' applied
2018-12-10 20:19:12,549 INFO     tuned.daemon.daemon: static tuning from profile 'openshift-node-es' applied

### remove the label
# oc label node ip-172-31-37-233.us-west-2.compute.internal node-role.kubernetes.io/elasticsearch-

# oc logs tuned-6pr67 | grep applied
2018-12-10 19:58:01,627 INFO     tuned.daemon.daemon: static tuning from profile 'openshift-node' applied
2018-12-10 20:19:12,549 INFO     tuned.daemon.daemon: static tuning from profile 'openshift-node-es' applied
2018-12-10 20:24:11,986 INFO     tuned.daemon.daemon: static tuning from profile 'openshift-node' applied

### modify a system param
# sysctl -n kernel.pid_max
131072

# oc edit cm tuned-profiles
- kernel.pid_max=>131072
+ kernel.pid_max=262144

### wait a bit
# sysctl -n kernel.pid_max
262144

### Notice that "(tuned 3.10 needed for =>)"
# tuned --version
tuned 2.10.0


```

Created [tuned-containerized/issues/1](https://github.com/jmencak/tuned-containerized/issues/1)

### Test with OCP 311

Deploy the operator:

```bash
# git clone https://github.com/openshift/cluster-node-tuning-operator.git
# cd cluster-node-tuning-operator/manifests/
# oc create -f ./01-namespace.yaml 
# oc project openshift-cluster-node-tuning-operator
# oc create -f 02-crd.yaml 
# oc create -f 03-rbac.yaml 
# oc create -f 04-operator.yaml

# oc get all
NAME                                                READY     STATUS    RESTARTS   AGE
pod/cluster-node-tuning-operator-78f87b497b-d78tc   1/1       Running   0          16m
pod/tuned-4blhm                                     1/1       Running   0          16m
pod/tuned-dm59j                                     1/1       Running   0          16m
pod/tuned-p85qr                                     1/1       Running   0          16m

NAME                   DESIRED   CURRENT   READY     UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
daemonset.apps/tuned   3         3         3         3            3           <none>          16m

NAME                                           DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/cluster-node-tuning-operator   1         1         1            1           16m

NAME                                                      DESIRED   CURRENT   READY     AGE
replicaset.apps/cluster-node-tuning-operator-78f87b497b   1         1         1         16m

```

| case\setup                                   | ocp 3.11 | origin 4.0: installer 0.6.0    |
|----------------------------------------------|----------|--------------------------------|
| A. es pod labeling                           | Y        | Y* (need restart pod manually) |
| B1. kernel.pid_max=>131072                   | Y        | N (wait until tuned 2.10.0)    |
| B2. net.netfilter.nf_conntrack_max=1048573   | Y        | Y                              |
| C. priority: 15#from 40 for `openshift-node` | Y        | Y                              |


### Test with OCP 4.0

After `openshift-install create cluster` (and `export KUBECONFIG=${PWD}/auth/kubeconfig`):

```bash
$ oc version
oc v4.0.0-0.94.0
kubernetes v1.11.0+3db990d20d
features: Basic-Auth GSSAPI Kerberos SPNEGO

Server https://hongkliu-api.devcluster.openshift.com:6443
kubernetes v1.11.0+231d012

$ oc get all -n openshift-cluster-node-tuning-operator
NAME                                                READY     STATUS    RESTARTS   AGE
pod/cluster-node-tuning-operator-7676f485cc-zp9pp   1/1       Running   0          1h
pod/tuned-827wp                                     1/1       Running   1          1h
pod/tuned-85cgm                                     1/1       Running   0          1h
pod/tuned-9fvrf                                     1/1       Running   0          1h
pod/tuned-nn69g                                     1/1       Running   1          1h
pod/tuned-pbkqx                                     1/1       Running   0          1h
pod/tuned-zz4m5                                     1/1       Running   1          1h

NAME                   DESIRED   CURRENT   READY     UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
daemonset.apps/tuned   6         6         6         6            6           <none>          1h

NAME                                           DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/cluster-node-tuning-operator   1         1         1            1           1h

NAME                                                      DESIRED   CURRENT   READY     AGE
replicaset.apps/cluster-node-tuning-operator-7676f485cc   1         1         1         1h

$ oc get cm -n openshift-cluster-node-tuning-operator
NAME              DATA      AGE
tuned-profiles    1         1h
tuned-recommend   1         1h

$ oc get tuned
NAME      AGE
default   9m

```

Check on nodes: `tuned` is not even installed.

```bash
# systemctl status tuned.service
Unit tuned.service could not be found.

```

Check the image version:

```bash
$ oc get ds tuned -o json | jq -r .spec.template.spec.containers[].image
registry.svc.ci.openshift.org/openshift/origin-v4.0-2018-12-11-071126@sha256:6667ac4aecae183dfd4e6ae4277dd86ca977e0a3b9feefee653043105503c6d6
$ oc get deploy -o json cluster-node-tuning-operator | jq -r .spec.template.spec.containers[].image
registry.svc.ci.openshift.org/openshift/origin-v4.0-2018-12-11-071126@sha256:04b6a2c614fb3840782db830c5739ff00b74ba596c768b0c4de457b5584bdecd

```

[Jiri's Demo](https://primetime.bluejeans.com/a2m/events/playback/fcda2a58-e664-4ff3-be05-0c3df8ae8604): at 01:41:01

```bash
$ oc project openshift-cluster-node-tuning-operator

$ oc get tuned default -o yaml | grep recommend -A 20
  recommend:
  - match:
    - label: tuned.openshift.io/elasticsearch
      match:
      - label: node-role.kubernetes.io/master
      - label: node-role.kubernetes.io/infra
      type: pod
    priority: 10
    profile: openshift-control-plane-es
  - match:
    - label: tuned.openshift.io/elasticsearch
      type: pod
    priority: 20
    profile: openshift-node-es
  - match:
    - label: node-role.kubernetes.io/master
    - label: node-role.kubernetes.io/infra
    priority: 30
    profile: openshift-control-plane
  - priority: 40
    profile: openshift-node

###not found any logging project/pod installed
###fake my own
$ oc new-project my-logging-project
$ oc create -f https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/pod_test.yaml
$ oc label pod web -n my-logging-project  tuned.openshift.io/elasticsearch=
$ oc get pod -o wide
NAME      READY     STATUS    RESTARTS   AGE       IP           NODE                                        NOMINATED NODE
web       1/1       Running   0          10s       10.128.2.8   ip-10-0-159-78.us-west-2.compute.internal   <none>

$ oc project openshift-cluster-node-tuning-operator
$ oc get pod -o wide | grep 78 | grep tuned
tuned-5rr44                                     1/1       Running   0          46m       10.0.159.78    ip-10-0-159-78.us-west-2.compute.internal    <none>

###not seeing expected log in tuned pod
###from Jiri: Need to fix
E1214 14:50:31.839156       7 streamwatcher.go:109] Unable to decode an event from the watch stream: http2: server sent GOAWAY and closed the connection; LastStreamID=3, ErrCode=NO_ERROR, debug=""

###workaround from Jiri:
$ oc delete pod tuned-5rr44
$ oc get pod -o wide | grep 78 | grep tuned
tuned-zkc48                                     1/1       Running   0          12s       10.0.159.78    ip-10-0-159-78.us-west-2.compute.internal    <none>
[fedora@ip-172-31-32-37 bbb]$ oc logs tuned-zkc48  | grep applied
2018-12-14 15:40:24,637 INFO     tuned.daemon.daemon: static tuning from profile 'openshift-node-es' applied

$ oc get cm tuned-profiles -o yaml | grep kernel.pid_max
      kernel.pid_max=>131072
### on one of master:
# sysctl -n kernel.pid_max
32768

### So the parameter (with `=>`) is NOT working either.

$ oc rsh tuned-<hash>  
sh-4.2# tuned --version
tuned 2.9.0
### we will have to wait until 2.10.0 is used in the centos pod


### changed the value of `net.netfilter.nf_conntrack_max`
$ oc edit tuned default

### on master `$ sysctl net.netfilter.nf_conntrack_max` shows the updated value
### the logs of tuned also shows one more line of `applied`.

### priority
### change the priority from 40 to 15 for profile `openshift-node`
$ oc edit tuned default
  - priority: 15
    profile: openshift-node

$ oc logs tuned-zkc48  | grep applied
2018-12-14 15:40:24,637 INFO     tuned.daemon.daemon: static tuning from profile 'openshift-node-es' applied
2018-12-14 16:00:08,949 INFO     tuned.daemon.daemon: static tuning from profile 'openshift-node' applied

```

## Test Automation
TODO

Function case:

We could automate the above test cases.
The routine is somehow
1. change a param by `oc edit tuned default` or `oc apply -f filename.yaml`
2. check (with a timeout) if the expect line shows up in the log of the tuned pod
3. check (with a timeout) if the param is updated on the node

We could use test utils from operator-framework: https://github.com/operator-framework/operator-sdk/tree/master/test/test-framework
Or implement the above logic without the framework.

System case:
Check how long it takes to pass 1 change onto monster cluster.

## custom profiles

Change `tuned.openshift.io/v1` to `tuned.openshift.io/v1alpha1`
depending whether you have a deployment with [pull/41](https://github.com/openshift/cluster-node-tuning-operator/pull/41) merged or not.

```
# oc get tuned default -o json | jq -r .apiVersion
tuned.openshift.io/v1alpha1
```

Test steps:

```
$ $ oc get node
NAME                                         STATUS    ROLES     AGE       VERSION
ip-10-0-130-163.us-east-2.compute.internal   Ready     master    8h        v1.12.4+6a9f178753
ip-10-0-136-210.us-east-2.compute.internal   Ready     worker    8h        v1.12.4+6a9f178753
ip-10-0-144-147.us-east-2.compute.internal   Ready     worker    8h        v1.12.4+6a9f178753
ip-10-0-156-224.us-east-2.compute.internal   Ready     master    8h        v1.12.4+6a9f178753
ip-10-0-165-241.us-east-2.compute.internal   Ready     worker    8h        v1.12.4+6a9f178753
ip-10-0-167-195.us-east-2.compute.internal   Ready     master    8h        v1.12.4+6a9f178753

$ oc project
Using project "openshift-cluster-node-tuning-operator" on server "https://api.jmencak.perf-testing.devcluster.openshift.com:6443".

$ oc create -f - <<EOF
###apiVersion: tuned.openshift.io/v1
apiVersion: tuned.openshift.io/v1alpha1
kind: Tuned
metadata:
  name: router
  namespace: openshift-cluster-node-tuning-operator
spec:
  profile:
  - data: |
      [main]
      summary=A custom OpenShift profile for the router
      include=openshift-control-plane

      [sysctl]
      net.ipv4.ip_local_port_range="1000 65535"
      net.ipv4.tcp_tw_reuse=1

    name: openshift-router

  recommend:
  - match:
    - label: app
      value: "router"
      type: pod
    priority: 5
    profile: openshift-router
EOF
tuned.tuned.openshift.io/router created

$ oc get tuned
NAME      AGE
default   6h10m
router    28s

$ oc get cm/tuned-profiles -o yaml|grep router
    openshift-router: |
      summary=A custom OpenShift profile for the router
    name: router

$ oc get cm/tuned-recommend -o yaml|grep router
    [openshift-router,0]
    /var/lib/tuned/ocp-pod-labels.cfg=.*\bapp=router\n
    name: router

$ oc get pods --all-namespaces --show-labels -o wide |grep router
openshift-ingress                            router-default-77c9ddb9cf-47nz7                                                1/1     Running     0          7h25m   10.131.0.4     ip-10-0-165-241.us-east-2.compute.internal   <none>           app=router,pod-template-hash=77c9ddb9cf,router=router-default
openshift-ingress                            router-default-77c9ddb9cf-crf69                                                1/1     Running     0          7h25m   10.128.2.3     ip-10-0-136-210.us-east-2.compute.internal   <none>           app=router,pod-template-hash=77c9ddb9cf,router=router-default


### check on the router nodes:  ip-10-0-165-241.us-east-2.compute.internal and ip-10-0-136-210.us-east-2.compute.internal
### use oc debug node/ip-10-0-165-241.us-east-2.compute.internal when you do not have the jump node
### currently, oc-debug-node is blocked by https://bugzilla.redhat.com/show_bug.cgi?id=1679625
$ ssh core@ip-10-0-165-241.us-east-2.compute.internal
$ sysctl net.ipv4.ip_local_port_range
net.ipv4.ip_local_port_range = 1000	65535
$ sysctl net.ipv4.tcp_tw_reuse
net.ipv4.tcp_tw_reuse = 1


# Check nodes which do NOT have the router
$ ssh core@ip-10-0-144-147.us-east-2.compute.internal
$ sysctl net.ipv4.ip_local_port_range
net.ipv4.ip_local_port_range = 32768	60999
[core@ip-10-0-144-147 ~]$ sysctl net.ipv4.tcp_tw_reuse
net.ipv4.tcp_tw_reuse = 0

$ oc get pods -o wide
NAME                                            READY   STATUS    RESTARTS   AGE   IP             NODE                                         NOMINATED NODE
cluster-node-tuning-operator-86bff68bb7-j7t5t   1/1     Running   0          8h    10.129.0.19    ip-10-0-167-195.us-east-2.compute.internal   <none>
tuned-7t5v8                                     1/1     Running   0          8h    10.0.136.210   ip-10-0-136-210.us-east-2.compute.internal   <none>
tuned-cnhs6                                     1/1     Running   0          8h    10.0.167.195   ip-10-0-167-195.us-east-2.compute.internal   <none>
tuned-dm4f5                                     1/1     Running   0          8h    10.0.130.163   ip-10-0-130-163.us-east-2.compute.internal   <none>
tuned-nfl4l                                     1/1     Running   0          8h    10.0.165.241   ip-10-0-165-241.us-east-2.compute.internal   <none>
tuned-r7rsk                                     1/1     Running   0          8h    10.0.156.224   ip-10-0-156-224.us-east-2.compute.internal   <none>
tuned-wggkl                                     1/1     Running   0          8h    10.0.144.147   ip-10-0-144-147.us-east-2.compute.internal   <none>

### tuned pods on router nodes
$ oc logs tuned-7t5v8 | grep profile | tail -n1
2019-02-21 21:09:47,421 INFO     tuned.daemon.daemon: static tuning from profile 'openshift-router' applied

### tuned pods on NON-router nodes
$ oc logs tuned-wggkl | grep profile | tail -n1
2019-02-21 21:10:30,296 INFO     tuned.daemon.daemon: static tuning from profile 'openshift-node' applied

### 
$ oc logs tuned-cnhs6 | grep profile | tail -n1
2019-02-21 21:11:10,271 INFO     tuned.daemon.daemon: static tuning from profile 'openshift-control-plane' applied

```