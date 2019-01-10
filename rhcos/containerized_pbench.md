# Containerized Pbench
Pbench is not installed on Atomic Host instances. We need to run pbench-agent on a container
to collect data.

## Run pbench-agent on cluster nodes
We have 4 nodes cluster as usual: 1 master, 1 infra, and 2 compute nodes.

Launch a node based on an AMI where <code>git</code> and <code>oc</code> are installed already.
Scp the kube config from master to that node:

```sh
[fedora@ip-172-31-33-174 ~]$ scp -i id_rsa_perf root@ec2-54-214-83-41.us-west-2.compute.amazonaws.com:/etc/origin/master/admin.kubeconfig .kube/config
[fedora@ip-172-31-33-174 ~]$ oc get nodes
NAME                                          STATUS                     AGE       VERSION
ip-172-31-21-233.us-west-2.compute.internal   Ready,SchedulingDisabled   2h        v1.7.0+80709908fd
ip-172-31-30-221.us-west-2.compute.internal   Ready                      2h        v1.7.0+80709908fd
ip-172-31-4-139.us-west-2.compute.internal    Ready                      2h        v1.7.0+80709908fd
ip-172-31-46-42.us-west-2.compute.internal    Ready                      2h        v1.7.0+80709908fd

# #we want to collect pbench data from master too
[fedora@ip-172-31-33-174 ~]$ oc adm manage-node ip-172-31-21-233.us-west-2.compute.internal --schedulable=true

# #create project/namespace to hold pbench-agent pods
[fedora@ip-172-31-33-174 ~]$ oc adm new-project pbench-controller --node-selector=""
[fedora@ip-172-31-33-174 ~]$ oc project pbench-controller
```


Follow [the steps](https://github.com/chaitanyaenr/scale-testing) to launch pbench-agent pods:

```sh
[fedora@ip-172-31-33-174 ~]$ git clone https://github.com/chaitanyaenr/scale-testing.git
[fedora@ip-172-31-33-174 ~]$ oc label node ip-172-31-21-233.us-west-2.compute.internal type=pbench
[fedora@ip-172-31-33-174 ~]$ oc label node ip-172-31-30-221.us-west-2.compute.internal type=pbench
[fedora@ip-172-31-33-174 ~]$ oc label node ip-172-31-4-139.us-west-2.compute.internal type=pbench
[fedora@ip-172-31-33-174 ~]$ oc label node ip-172-31-46-42.us-west-2.compute.internal type=pbench
[fedora@ip-172-31-33-174 ~]$ oc create serviceaccount useroot
[fedora@ip-172-31-33-174 ~]$ oc adm policy add-scc-to-user privileged -z useroot
[fedora@ip-172-31-33-174 ~]$ oc create -f ./scale-testing/openshift-templates/pbench-agent-daemonset.yml
daemonset "pbench-agent" created
[fedora@ip-172-31-33-174 ~]$ oc patch daemonset pbench-agent --patch \ '{"spec":{"template":{"spec":{"serviceAccountName": "useroot"}}}}'
daemonset "pbench-agent" patched
[fedora@ip-172-31-33-174 ~]$ oc get pod -o wide
NAME                 READY     STATUS    RESTARTS   AGE       IP              NODE
pbench-agent-lh1wb   1/1       Running   0          24s       172.31.4.139    ip-172-31-4-139.us-west-2.compute.internal
pbench-agent-p0g19   1/1       Running   0          24s       172.31.21.233   ip-172-31-21-233.us-west-2.compute.internal
pbench-agent-tth7x   1/1       Running   0          24s       172.31.30.221   ip-172-31-30-221.us-west-2.compute.internal
pbench-agent-tvdrk   1/1       Running   0          24s       172.31.46.42    ip-172-31-46-42.us-west-2.compute.internal
[fedora@ip-172-31-33-174 ~]$ oc get ds
NAME           DESIRED   CURRENT   READY     UP-TO-DATE   AVAILABLE   NODE-SELECTOR   AGE
pbench-agent   4         4         4         4            4           type=pbench     50s

```

## Collectd (Optional)

```sh
[fedora@ip-172-31-33-174 ~]$ vi scale-testing/openshift-templates/collectd-config.yml
apiVersion: v1
kind: ConfigMap
metadata:
  name: collectd-config
data:
  host: "perf-infra.ec2.breakage.org"
  prefix: "hongkliu_ocp"
  interval: "10"

[fedora@ip-172-31-33-174 ~]$ oc create -f ./scale-testing/openshift-templates/collectd-config.yml
[fedora@ip-172-31-33-174 ~]$ oc create -f ./scale-testing/openshift-templates/collectd-daemonset.yml
[fedora@ip-172-31-33-174 ~]$ oc patch daemonset collectd --patch \ '{"spec":{"template":{"spec":{"serviceAccountName": "useroot"}}}}'
[fedora@ip-172-31-33-174 ~]$ oc get ds collectd
NAME       DESIRED   CURRENT   READY     UP-TO-DATE   AVAILABLE   NODE-SELECTOR   AGE
collectd   4         4         4         4            4           type=pbench     14s
```

Then we can check the real-time data of CPU, MEM ... on [Grafana server](http://perf-infra.ec2.breakage.org:3000/dashboard/db/openshift-scale-lab-3-7?from=now-15m&to=now&var-Cloud=hongkliu_ocp&var-Node=ip-172-31-21-233_us-west-2_compute_internal&var-Interface=&var-Disk=&var-cpus0=All&var-cpus00=All).

## Pbench controller node (NOT working yet)
We use another instance based on AMI-gold as pbench-controller node.

```sh
(awsenv) [hongkliu@hongkliu awscli]$ aws ec2 run-instances --image-id ami-1e76b166  --security-group-ids sg-5c5ace38 --count 1 --instance-type m4.xlarge --key-name id_rsa_perf     --subnet subnet-4879292d  --block-device-mappings "[{\"DeviceName\":\"/dev/sdb\", \"Ebs\":{\"VolumeSize\": 60}}]"     --query 'Instances[*].InstanceId'     --tag-specifications="[{\"ResourceType\":\"instance\",\"Tags\":[{\"Key\":\"Name\",\"Value\":\"qe-hongkliu-test-pbench-jn\"}]}]"
```

Prepare keys in <code>./scale-testing/keys/</code>:

* id_rsa: private key to pbench-server: /opt/pbench-agent/id_rsa on AMI-gold
* id_rsa_perf: we should have this key already

```sh
# docker pull ravielluri/image:controller
# docker tag ravielluri/image:controller pbench-controller:latest
# vi ./scale-testing/run.sh
#!/bin/sh

#files_dir=/root/scale-testing
files_dir=/home/fedora/scale-testing
docker run -t -d --name=controller --net=host --privileged \
    -v $files_dir/results:/var/lib/pbench-agent \
    -v $files_dir/inventory:/root/inventory \
    -v $files_dir/vars:/root/vars \
    -v $files_dir/keys:/root/.ssh \
    -v $files_dir/benchmark.sh:/root/benchmark.sh pbench-controller

# vi scale-testing/vars
KUBECONFIG=/home/fedora/.kube/config
benchmark_type=nodeVertical
benchmark=/root/benchmark.sh
pbench_server=perf-infra.ec2.breakage.org
move_results=True

# #this is the bench-mark script for the test
# vi scale-testing/benchmark.sh
#!/bin/bash
pbench-user-benchmark -- sleep 30

# vi scale-testing/inventory
[pbench-controller]
172.31.16.131

[masters]
172.31.21.233

[etcd]
172.31.21.233

[lb]
#172.16.0.19

[glusterfs]
#172.16.0.11 openshift_schedulable=false openshift_node_labels="{'region': 'primary', 'zone': 'default'}"
#172.16.0.9 openshift_schedulable=false openshift_node_labels="{'region': 'primary', 'zone': 'default'}"
#172.16.0.18 openshift_schedulable=false openshift_node_labels="{'region': 'primary', 'zone': 'default'}"

[nodes]
# masters
172.31.21.233 openshift_schedulable=true

# infra nodes (routers/registry)
172.31.30.221 openshift_node_labels="{'region': 'infra', 'zone': 'default'}"
#172.16.0.16 openshift_node_labels="{'region': 'infra', 'zone': 'default'}"
#172.16.0.12 openshift_node_labels="{'region': 'infra', 'zone': 'default'}"

## worker nodes
172.31.4.139 openshift_node_labels="{'region': 'primary', 'zone': 'default'}"
172.31.46.42 openshift_node_labels="{'region': 'primary', 'zone': 'default'}"

[prometheus-metrics]
172.31.21.233 port=8443 cert=/etc/origin/master/admin.crt key=/etc/origin/master/admin.key
172.31.30.221 port=10250  cert=/etc/origin/master/admin.crt key=/etc/origin/master/admin.key
172.31.4.139 port=10250  cert=/etc/origin/master/admin.crt key=/etc/origin/master/admin.key
172.31.46.42 port=10250  cert=/etc/origin/master/admin.crt key=/etc/origin/master/admin.key
#172.16.0.17 port=10250  cert=/etc/origin/master/admin.crt key=/etc/origin/master/admin.key
#172.16.0.16 port=10250  cert=/etc/origin/master/admin.crt key=/etc/origin/master/admin.key
#172.16.0.12 port=10250  cert=/etc/origin/master/admin.crt key=/etc/origin/master/admin.key
#172.16.0.10 port=10250  cert=/etc/origin/master/admin.crt key=/etc/origin/master/admin.key
#172.16.0.6 port=10250  cert=/etc/origin/master/admin.crt key=/etc/origin/master/admin.key

[pbench-controller:vars]
register_all_nodes=True

# vi scale-testing/keys/config
Host 172.31.16.131
        HostName 172.31.16.131
        User root
        Port 22
        StrictHostKeyChecking no
        IdentityFile ~/.ssh/id_rsa_perf


Host ec2-54-191-246-139.us-west-2.compute.amazonaws.com
        HostName ec2-54-191-246-139.us-west-2.compute.amazonaws.com
        User pbench
        Port 22
        StrictHostKeyChecking no
        PasswordAuthentication no
        IdentityFile /opt/pbench-agent/id_rsa

Host perf-infra.ec2.breakage.org
        HostName perf-infra.ec2.breakage.org
        User pbench
        Port 22
        StrictHostKeyChecking no
        PasswordAuthentication no
        IdentityFile /opt/pbench-agent/id_rsa


Host *
	User root
        Port 2022
        StrictHostKeyChecking no
        PasswordAuthentication no
        IdentityFile ~/.ssh/id_rsa_perf

Host *perf.lab.eng.bos.redhat.com
        User root
        Port 22
        StrictHostKeyChecking no



# #run the container
# ./scale-testing/run.sh
```

The pods actually runs a script which includes running the playbook defined [here](https://github.com/distributed-system-analysis/pbench/blob/master/contrib/ansible/openshift/pbench_register.yml).

No error in the log of the docker container _controller_, however, the [pbench data on the server](http://perf-infra.ec2.breakage.org/pbench/results/ip-172-31-16-131/) is empty.

TODO: Fix


## Pbench controller node: Old school

Copy the above ssh config

```sh
# cp scale-testing/keys/config ~/.ssh/config
# vi my-pbench-register.sh
#!/bin/sh

pbench-stop-tools
pbench-kill-tools
pbench-clear-tools


pbench-register-tool-set --remote=ip-172-31-21-233.us-west-2.compute.internal --interval=10
pbench-register-tool --name=oc --remote=ip-172-31-21-233.us-west-2.compute.internal
pbench-register-tool --name=pprof --remote=ip-172-31-21-233.us-west-2.compute.internal -- --osecomponent=master

pbench-register-tool-set --remote=ip-172-31-30-221.us-west-2.compute.internal --interval=10
pbench-register-tool --name=pprof --remote=ip-172-31-30-221.us-west-2.compute.internal -- --osecomponent=node

pbench-register-tool-set --remote=ip-172-31-4-139.us-west-2.compute.internal --interval=10
pbench-register-tool --name=pprof --remote=ip-172-31-4-139.us-west-2.compute.internal -- --osecomponent=node

pbench-register-tool-set --remote=ip-172-31-46-42.us-west-2.compute.internal --interval=10
pbench-register-tool --name=pprof --remote=ip-172-31-46-42.us-west-2.compute.internal -- --osecomponent=node

pbench-list-tools

# chmod +x my-pbench-register.sh
# ./my-pbench-register.sh

# pbench-start-tools --dir=/var/lib/pbench-agent/hk-test-name
# #run your test
# #stop/post-process/
# #copy
```

We can see ssh config is crucial here because ssh connects to cluster instances via 2022 port.
That port is actually served by pbench-agent pods on those instances. Pbench also uses ssh to send commands on those instances.

```sh
# ssh ip-172-31-21-233.us-west-2.compute.internal
System is booting up. See pam_nologin(8)
Last login: Thu Oct 12 00:47:42 2017 from ip-172-31-16-131.us-west-2.compute.internal

[root@ip-172-31-21-233 ~]# yum list install pbench-agent
...
Installed Packages
pbench-agent.noarch                                   0.45-36g124b3a8                                    @ndokos-pbench-interim
```

Check [pbench data on the server](http://perf-infra.ec2.breakage.org/pbench/results/ip-172-31-16-131/).

Note that <code>pprof</code> seems not working on that pbench-agent pods. But that is
OK for now. It is [WIP](https://github.com/distributed-system-analysis/pbench/pull/676).
