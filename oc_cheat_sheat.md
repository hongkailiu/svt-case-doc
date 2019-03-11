
## [journalctl](https://www.loggly.com/ultimate-guide/using-journalctl/)

```sh
# systemctl list-unit-files --all
# journalctl -u atomic-openshift-node.service
```

## authentication

```sh
$ oc whoami
$ oc login -u redhat -p <password>
$ oc login -u system:admin
$ oc adm policy add-cluster-role-to-user cluster-admin redhat
###
# htpasswd -b /etc/origin/master/htpasswd redhat <password>
###
# oc get csr -o name | xargs oc adm certificate approve
```

## check on which node a pod runs

```sh
$ oc get pods -o wide
```

## custom oc output

```sh
# oc get pod tuned-bqlws -o custom-columns=name:.spec.containers[].name
name
tuned
```

## delete project

```sh
$ oc delete project -l purpose=test
$ for i in {110..119}; do oc delete project "proj$i"; done
$ oc get projects | cut -f1 -d" " | grep -E "proj[0-9]+" | while read i; do oc delete project $i; done
```

## delete build

```
$ oc get builds --all-namespaces | grep Fail | grep -E "proj[0-9]+" | while read i; do awk '{system("oc delete build -n " $1 "  " $2)}'; done
```

## Clean docker images

```sh
# docker images | grep -E "proj[0-9]+" | awk '{print $3}' | while read i; do docker rmi $i; done
```

## Show sha of docker images

```sh
# docker images --digests
```

## Extend docker fs

```sh
# oc get nodes --no-headers | cut -f1 -d" " | while read i; do ssh -n "$i" 'xfs_growfs -d /var/lib/docker/overlay2'; done
```

## remove a computing node from cluster

  - on the computing node

  ```sh
  # systemctl stop atomic-openshift-node
  # systemctl disable atomic-openshift-node
  ```

  - on a master node

  ```sh
  # oc get nodes
  # oc delete node <node_name>
  ```
## restart ectd

```sh
# systemctl restart etcd
```

## get log from container in pod

```sh
$ oc logs <pod_name> -c kibana --loglevel=10
```

## get all objects of a project

```sh
$ oc project <project_name>
$ oc get all
```

## new-app

```sh
# oc new-app https://github.com/dev-tool-index/calculator-monitor-docker
```

## config and restart master

```sh
# vi /etc/origin/master/master-config.yaml
# systemctl restart atomic-openshift-master
```

## Config maximal volumes

### 3.6 and HA

```sh
# #on all masters:
# vi /etc/sysconfig/atomic-openshift-master-controllers
...
KUBE_MAX_PD_VOLS=60

# systemctl daemon-reload
# systemctl restart atomic-openshift-master-controllers
```

## yum

```
### list all pbench-fio versions
# yum --showduplicates list pbench-fio
### install a specific version
yum install pbench-fio-2.14
```


## cns

```sh
# clean up pv left-overs
# oc get pv | grep fio | awk '{print $1}' | while read i; do oc delete pv $i; done
# oc get pv --no-headers | grep -v etcd | awk '{print $1}' | while read i; do oc delete pv $i; done

# systemctl stop lvm2-lvmetad.service 
# systemctl stop lvm2-lvmetad.socket 
# systemctl start lvm2-lvmetad.socket 
# systemctl start lvm2-lvmetad.service 

# rm -rf /var/lib/heketi/
# oc get node -l glusterfs=storage-host --no-headers | grep compute | awk '{print $1}' | while read line; do ssh -n "${line}" 'rm -rfv /var/lib/heketi/'; done

# oc get pod -n glusterfs -o yaml | grep "image:" | sort -u

# oc get node --show-labels | grep gluster | awk '{print $1}' | while read i; do oc adm manage-node $i --schedulable=false; done
# oc get node | grep cns | awk '{print $1}' | while read i; do oc adm manage-node $i --schedulable=false; done

# oc get pod -n glusterfs | grep glusterfs-storage | awk '{print $1}' | while read line; do oc exec -n glusterfs "$line" -- systemctl status gluster-blockd.service; done | grep Active
# oc get pod -n glusterfs | grep glusterfs-storage | awk '{print $1}' | while read line; do oc exec -n glusterfs "$line" -- systemctl status glusterd.service; done | grep Active
```

### ocp node role

```sh
$ oc label node hongkliu-310-bbb-nrr-1 node-role.kubernetes.io/infra=true
```

## Jenkins image is missing for master branch

```sh
$ oc get imagestreamtag -n openshift | grep jenkins
$ oc get imagestream -n openshift | grep jenkins
$ oc edit imagestream -n openshift jenkins
$ oc import-image -n openshift jenkins
```
## oc explain

```sh
$ oc explain DeploymentConfig.spec.template.spec
```

What if same name with different version?

```
# oc api-resources | grep deployments
deployments                           deploy         apps                           true         Deployment
deployments                           deploy         extensions                     true         Deployment
```

```bash
# oc api-versions  -h
Print the supported API versions on the server, in the form of "group/version"

# oc api-versions  | grep -E "apps|extensions"
apiextensions.k8s.io/v1beta1
apps.openshift.io/v1
apps/v1
apps/v1beta1
apps/v1beta2
extensions/v1beta1

```

Then,

```bash
# oc explain deployments --api-version='apps/v1'
```


## pbench-fio leftover

```sh
# ps -ef | grep pbench | grep fio | awk '{print $2}' | while read i; do kill "$i"; done
# oc get node --no-headers | awk '{print $1}' | while read line; do ssh -n "${line}" 'curl -LO https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/scripts/clean_pbench_processes.sh'; done
# oc get node --no-headers | awk '{print $1}' | while read line; do ssh -n "${line}" 'bash -x ./clean_pbench_processes.sh'; done

# oc get node --no-headers | awk '{print $1}' | while read line; do ssh -n "${line}" 'ps -ef | grep pbench'; done
# oc get node --no-headers | awk '{print $1}' | while read line; do ssh -n "${line}" 'pbench-clear-results'; done

```

## Scale lab:

```sh
###access to Alderaan
$ ec2.sh b03-h01-1029p.rdu.openstack.engineering.redhat.com
<akrzos> is the undercloud machine
<akrzos> root/100yard-
<akrzos> or perf key
<akrzos> sudo su - stack
<akrzos> . overcloudrc
<akrzos> openstack server list --all
<akrzos> will show the instances

###or
$ ssh  -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa_perf stack@b03-h01-1029p.rdu.openstack.engineering.redhat.com

[stack@b03-h01-1029p ~]$ ssh root@ansible-host
# cd /home/cloud-user/
### https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/gfs_inv.file
# ansible-playbook -i /tmp/gfs_inv.file openshift-ansible/playbooks/openshift-glusterfs/uninstall.yml
# ansible-playbook -i /tmp/gfs_inv.file openshift-ansible/playbooks/openshift-glusterfs/config.yml 
# kubectl patch storageclass glusterfs-storage -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

```sh
###laptop on VPN
$ cat /etc/hosts
...
### openstack server list --all
### lb-0.scale-ci.example.com 10.12.80.37
### infra-node-1.scale-ci.example.com 10.12.80.27
10.12.80.37 lb-0.scale-ci.example.com
10.12.80.27 registry-console-default.apps.scale-ci.example.com
10.12.80.27 jenkins-storage-test-jenkins-1.apps.scale-ci.example.com
...
###https://lb-0.scale-ci.example.com:8443
```

```sh
# ansible-playbook -i "ansible-host," jenkins-test.yaml --tags run
# pbench-move-results --prefix=jenkins_test_results
```

## [list the namespaced resources](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/#not-all-objects-are-in-a-namespace)

```bash
$ kubectl api-resources --namespaced=true

```

## oc debug 

```
$ oc version
oc v4.0.0-0.177.0
kubernetes v1.12.4+6a9f178753
features: Basic-Auth GSSAPI Kerberos SPNEGO
...
$ oc debug node/ip-10-0-133-100.us-east-2.compute.internal -- chroot /host journalctl -u kubelet.service -f 
$ oc get node --no-headers | awk '{print $1}' |  while read i; do oc debug node/$i -- chroot /host ls -al .; done
$ oc get node --no-headers | awk '{print $1}' | while read i; do echo "node: $i"; oc debug node/$i -- curl -s http://169.254.169.254/latest/meta-data/local-hostname; done

$ oc get node -l role=storage-node | awk '{print $1}' | while read i; do oc debug node/$i -- lsblk; done

```

## oc image

```
$ oc image extract quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:5ccc80b91aad3a03440d784a09f21ea89d7007a73b9f01210d6c5925340b2650 --path /usr/bin/openshift-install:./abc/
$ oc image extract quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:5ccc80b91aad3a03440d784a09f21ea89d7007a73b9f01210d6c5925340b2650 --file  /usr/bin/openshift-install

```