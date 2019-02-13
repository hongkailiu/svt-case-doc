# [rook](https://rook.io/)

* [rook.io](https://rook.io/), [rook@github](https://github.com/rook/rook)
* [Fabio Bertinatto's mojo](https://mojo.redhat.com/docs/DOC-1189365)
* [ceph@openshift/external-storage](https://github.com/openshift/external-storage/tree/master/ceph/cephfs)

## Installation

```
# go get -d github.com/rook/rook
# cd /root/go/src/github.com/rook/rook/cluster/examples/kubernetes/ceph/
### use the latest release branch
### I did not see osd pods with master on 20190205
# git checkout release-0.9

### set up privilege: https://rook.io/docs/rook/master/openshift.html
# oc create -f scc.yaml

# vi operator.yaml
### https://github.com/rook/rook/issues/2612
        - name: FLEXVOLUME_DIR_PATH
          value: "/etc/kubernetes/kubelet-plugins/volume/exec"
...
        - name: ROOK_HOSTPATH_REQUIRES_PRIVILEGED
          value: "true"

# oc create -f operator.yaml

# oc get pod -n rook-ceph-system
NAME                                  READY   STATUS    RESTARTS   AGE
rook-ceph-agent-bgtrt                 1/1     Running   0          39s
rook-ceph-agent-gcw8k                 1/1     Running   0          39s
rook-ceph-agent-h6bvl                 1/1     Running   0          39s
rook-ceph-operator-769d6854b9-tdtdv   1/1     Running   0          61s
rook-discover-9t8s4                   1/1     Running   0          39s
rook-discover-klgrm                   1/1     Running   0          39s
rook-discover-s2spl                   1/1     Running   0          39s

# oc create -f cluster.yaml

```

Tested on OCP 3.11: 1 master, 1 infra, and 3 compute nodes

```
# oc get pod -n rook-ceph-system -o wide
NAME                                  READY     STATUS    RESTARTS   AGE       IP             NODE                                         NOMINATED NODE
rook-ceph-agent-5nctb                 1/1       Running   0          2m        172.31.2.180   ip-172-31-2-180.us-west-2.compute.internal   <none>
rook-ceph-agent-cqxk8                 1/1       Running   0          2m        172.31.41.17   ip-172-31-41-17.us-west-2.compute.internal   <none>
rook-ceph-agent-hhm8l                 1/1       Running   0          2m        172.31.57.20   ip-172-31-57-20.us-west-2.compute.internal   <none>
rook-ceph-operator-8486446b75-6tfs6   1/1       Running   0          2m        172.20.2.2     ip-172-31-57-20.us-west-2.compute.internal   <none>
rook-discover-9qn4c                   1/1       Running   0          2m        172.23.0.2     ip-172-31-41-17.us-west-2.compute.internal   <none>
rook-discover-bcvkj                   1/1       Running   0          2m        172.20.2.3     ip-172-31-57-20.us-west-2.compute.internal   <none>
rook-discover-wswk2                   1/1       Running   0          2m        172.22.0.2     ip-172-31-2-180.us-west-2.compute.internal   <none>


### label compute nodes: otherwise some of the pods might choose infra node to run and our default node selector forbids it
# oc label node ip-172-31-2-180.us-west-2.compute.internal role=storage-node
# oc label node ip-172-31-41-17.us-west-2.compute.internal role=storage-node
# oc label node ip-172-31-57-20.us-west-2.compute.internal role=storage-node

### uncomment `placement.all` section in `CephCluster: rook-ceph`
# git diff
diff --git a/cluster/examples/kubernetes/ceph/cluster.yaml b/cluster/examples/kubernetes/ceph/cluster.yaml
index cbafb14..e760fcc 100755
--- a/cluster/examples/kubernetes/ceph/cluster.yaml
+++ b/cluster/examples/kubernetes/ceph/cluster.yaml
@@ -193,16 +193,16 @@ spec:
   # To control where various services will be scheduled by kubernetes, use the placement configuration sections below.
   # The example under 'all' would have all services scheduled on kubernetes nodes labeled with 'role=storage-node' and
   # tolerate taints with a key of 'storage-node'.
-#  placement:
-#    all:
-#      nodeAffinity:
-#        requiredDuringSchedulingIgnoredDuringExecution:
-#          nodeSelectorTerms:
-#          - matchExpressions:
-#            - key: role
-#              operator: In
-#              values:
-#              - storage-node
+  placement:
+    all:
+      nodeAffinity:
+        requiredDuringSchedulingIgnoredDuringExecution:
+          nodeSelectorTerms:
+          - matchExpressions:
+            - key: role
+              operator: In
+              values:
+              - storage-node
 #      podAffinity:
 #      podAntiAffinity:
 #      tolerations:
diff --git a/cluster/examples/kubernetes/ceph/operator.yaml b/cluster/examples/kubernetes/ceph/operator.yaml
index 73cde2e..ba4bab8 100755
--- a/cluster/examples/kubernetes/ceph/operator.yaml
+++ b/cluster/examples/kubernetes/ceph/operator.yaml
@@ -469,7 +469,7 @@ spec:
         # This is necessary to workaround the anyuid issues when running on OpenShift.
         # For more details see https://github.com/rook/rook/issues/1314#issuecomment-355799641
         - name: ROOK_HOSTPATH_REQUIRES_PRIVILEGED
-          value: "false"
+          value: "true"
         # In some situations SELinux relabelling breaks (times out) on large filesystems, and doesn't work with cephfs Rea
         # Disable it here if you have similiar issues.
         # For more details see https://github.com/rook/rook/issues/2417
(END)

# oc get all -o wide -n rook-ceph
NAME                                                               READY     STATUS      RESTARTS   AGE       IP            NODE                                         NOMINATED NODE
pod/rook-ceph-mgr-a-7f49c7fc9d-z679s                               1/1       Running     0          2m        172.23.0.11   ip-172-31-41-17.us-west-2.compute.internal   <none>
pod/rook-ceph-mon-a-5dfcf874d6-p8q2n                               1/1       Running     0          3m        172.22.0.12   ip-172-31-2-180.us-west-2.compute.internal   <none>
pod/rook-ceph-mon-b-f876666cd-l7c6s                                1/1       Running     0          3m        172.23.0.10   ip-172-31-41-17.us-west-2.compute.internal   <none>
pod/rook-ceph-mon-c-64dbfd4948-dqq4m                               1/1       Running     0          3m        172.20.2.10   ip-172-31-57-20.us-west-2.compute.internal   <none>
pod/rook-ceph-osd-0-6878d8d869-kkmpm                               1/1       Running     0          2m        172.20.2.12   ip-172-31-57-20.us-west-2.compute.internal   <none>
pod/rook-ceph-osd-1-79889c548d-57qmc                               1/1       Running     0          2m        172.22.0.14   ip-172-31-2-180.us-west-2.compute.internal   <none>
pod/rook-ceph-osd-2-6f65554bd6-9j6ht                               1/1       Running     0          2m        172.23.0.13   ip-172-31-41-17.us-west-2.compute.internal   <none>
pod/rook-ceph-osd-prepare-2ebcaafe00893021f84fa631d8017c38-9kfkk   0/2       Completed   0          2m        172.23.0.12   ip-172-31-41-17.us-west-2.compute.internal   <none>
pod/rook-ceph-osd-prepare-b0255163cf4ea85495820e7cea9924b4-wmww4   0/2       Completed   0          2m        172.22.0.13   ip-172-31-2-180.us-west-2.compute.internal   <none>
pod/rook-ceph-osd-prepare-f1c4be1d30ad9612f6cee9e157bc18c0-mkm9w   0/2       Completed   0          2m        172.20.2.11   ip-172-31-57-20.us-west-2.compute.internal   <none>

NAME                              TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE       SELECTOR
service/rook-ceph-mgr             ClusterIP   172.25.22.232   <none>        9283/TCP   2m        app=rook-ceph-mgr,rook_cluster=rook-ceph
service/rook-ceph-mgr-dashboard   ClusterIP   172.27.49.46    <none>        8443/TCP   2m        app=rook-ceph-mgr,rook_cluster=rook-ceph
service/rook-ceph-mon-a           ClusterIP   172.27.33.12    <none>        6790/TCP   3m        app=rook-ceph-mon,ceph_daemon_id=a,mon=a,mon_cluster=rook-ceph,rook_cluster=rook-ceph
service/rook-ceph-mon-b           ClusterIP   172.27.18.205   <none>        6790/TCP   3m        app=rook-ceph-mon,ceph_daemon_id=b,mon=b,mon_cluster=rook-ceph,rook_cluster=rook-ceph
service/rook-ceph-mon-c           ClusterIP   172.26.34.176   <none>        6790/TCP   3m        app=rook-ceph-mon,ceph_daemon_id=c,mon=c,mon_cluster=rook-ceph,rook_cluster=rook-ceph

NAME                              DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE       CONTAINERS   IMAGES                       SELECTOR
deployment.apps/rook-ceph-mgr-a   1         1         1            1           2m        mgr          ceph/ceph:v13.2.4-20190109   app=rook-ceph-mgr,ceph_daemon_id=a,instance=a,mgr=a,rook_cluster=rook-ceph
deployment.apps/rook-ceph-mon-a   1         1         1            1           3m        mon          ceph/ceph:v13.2.4-20190109   app=rook-ceph-mon,ceph_daemon_id=a,mon=a,mon_cluster=rook-ceph,rook_cluster=rook-ceph
deployment.apps/rook-ceph-mon-b   1         1         1            1           3m        mon          ceph/ceph:v13.2.4-20190109   app=rook-ceph-mon,ceph_daemon_id=b,mon=b,mon_cluster=rook-ceph,rook_cluster=rook-ceph
deployment.apps/rook-ceph-mon-c   1         1         1            1           3m        mon          ceph/ceph:v13.2.4-20190109   app=rook-ceph-mon,ceph_daemon_id=c,mon=c,mon_cluster=rook-ceph,rook_cluster=rook-ceph
deployment.apps/rook-ceph-osd-0   1         1         1            1           2m        osd          ceph/ceph:v13.2.4-20190109   app=rook-ceph-osd,ceph-osd-id=0,rook_cluster=rook-ceph
deployment.apps/rook-ceph-osd-1   1         1         1            1           2m        osd          ceph/ceph:v13.2.4-20190109   app=rook-ceph-osd,ceph-osd-id=1,rook_cluster=rook-ceph
deployment.apps/rook-ceph-osd-2   1         1         1            1           2m        osd          ceph/ceph:v13.2.4-20190109   app=rook-ceph-osd,ceph-osd-id=2,rook_cluster=rook-ceph

NAME                                         DESIRED   CURRENT   READY     AGE       CONTAINERS   IMAGES                       SELECTOR
replicaset.apps/rook-ceph-mgr-a-7f49c7fc9d   1         1         1         2m        mgr          ceph/ceph:v13.2.4-20190109   app=rook-ceph-mgr,ceph_daemon_id=a,instance=a,mgr=a,pod-template-hash=3905739758,rook_cluster=rook-ceph
replicaset.apps/rook-ceph-mon-a-5dfcf874d6   1         1         1         3m        mon          ceph/ceph:v13.2.4-20190109   app=rook-ceph-mon,ceph_daemon_id=a,mon=a,mon_cluster=rook-ceph,pod-template-hash=1897943082,rook_cluster=rook-ceph
replicaset.apps/rook-ceph-mon-b-f876666cd    1         1         1         3m        mon          ceph/ceph:v13.2.4-20190109   app=rook-ceph-mon,ceph_daemon_id=b,mon=b,mon_cluster=rook-ceph,pod-template-hash=943222278,rook_cluster=rook-ceph
replicaset.apps/rook-ceph-mon-c-64dbfd4948   1         1         1         3m        mon          ceph/ceph:v13.2.4-20190109   app=rook-ceph-mon,ceph_daemon_id=c,mon=c,mon_cluster=rook-ceph,pod-template-hash=2086980504,rook_cluster=rook-ceph
replicaset.apps/rook-ceph-osd-0-6878d8d869   1         1         1         2m        osd          ceph/ceph:v13.2.4-20190109   app=rook-ceph-osd,ceph-osd-id=0,pod-template-hash=2434848425,rook_cluster=rook-ceph
replicaset.apps/rook-ceph-osd-1-79889c548d   1         1         1         2m        osd          ceph/ceph:v13.2.4-20190109   app=rook-ceph-osd,ceph-osd-id=1,pod-template-hash=3544571048,rook_cluster=rook-ceph
replicaset.apps/rook-ceph-osd-2-6f65554bd6   1         1         1         2m        osd          ceph/ceph:v13.2.4-20190109   app=rook-ceph-osd,ceph-osd-id=2,pod-template-hash=2921110682,rook_cluster=rook-ceph

NAME                                                               DESIRED   SUCCESSFUL   AGE       CONTAINERS            IMAGES                                        SELECTOR
job.batch/rook-ceph-osd-prepare-2ebcaafe00893021f84fa631d8017c38   1         1            2m        copy-bins,provision   rook/ceph:v0.9.2,ceph/ceph:v13.2.4-20190109   controller-uid=7b48d20c-2962-11e9-9235-025ec4c47606
job.batch/rook-ceph-osd-prepare-b0255163cf4ea85495820e7cea9924b4   1         1            2m        copy-bins,provision   rook/ceph:v0.9.2,ceph/ceph:v13.2.4-20190109   controller-uid=7b47cd87-2962-11e9-9235-025ec4c47606
job.batch/rook-ceph-osd-prepare-f1c4be1d30ad9612f6cee9e157bc18c0   1         1            2m        copy-bins,provision   rook/ceph:v0.9.2,ceph/ceph:v13.2.4-20190109   controller-uid=7b49f098-2962-11e9-9235-025ec4c47606


### we can verify that the affinity is configured in the deployments:
# oc get deploy rook-ceph-mon-a -o yaml | grep storage -B 9
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: role
                operator: In
                values:
                - storage-node

# oc get deploy rook-ceph-mgr-a -o yaml | grep storage -B 9
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: role
                operator: In
                values:
                - storage-node


```

Configure ceph to [use Additional device](https://rook.io/docs/rook/v0.9/ceph-cluster-crd.html):

```
### Tested with 3 storage nodes with
### lsblk
...
nvme2n1     259:1    0 1000G  0 disk 

###
# vi cluster.yaml
spec:
  storage:
  ...
    devices:             # specific devices to use for storage can be specified for each node
      - name: "nvme2n1"
...

### after creating cluster and verify if the device is used on the storage nodes:
# lsblk | grep nvme2n1 -A1
nvme2n1                                                                                              259:1    0 1000G  0 disk 
└─ceph--12669933--fe96--4442--b2ef--9e1a2d269fdb-osd--data--46ce65a7--7a8d--4daf--b57e--a11a52637380 253:0    0 1000G  0 lvm  

### check the status by tool-box
# oc rsh -n rook-ceph rook-ceph-tools-98f57449f-msgdk
sh-4.2# ceph status
  cluster:
    id:     3899fd99-a392-4825-8b51-937564603084
    health: HEALTH_OK
 
  services:
    mon: 3 daemons, quorum a,c,b
    mgr: a(active)
    osd: 3 osds: 3 up, 3 in
 
  data:
    pools:   1 pools, 100 pgs
    objects: 0  objects, 0 B
    usage:   3.0 GiB used, 2.9 TiB / 2.9 TiB avail
    pgs:     100 active+clean


```

Troubleshooting:

```
### the operator seems to keep tracking of previous install, so recover the cluster
# oc delete -f cluster.yaml
# oc delete -f operator.yaml
# oc get node --no-headers | awk '{print $1}' | while read line; do ssh -n "${line}" 'ls -al /var/lib/rook'; done
# oc get node --no-headers | awk '{print $1}' | while read line; do ssh -n "${line}" 'rm -rf /var/lib/rook'; done

```

## [Shared File System](https://rook.io/docs/rook/v0.9/ceph-filesystem.html)

```
###
# oc create -f filesystem.yaml
# oc -n rook-ceph get pod -l app=rook-ceph-mds
NAME                                    READY     STATUS    RESTARTS   AGE
rook-ceph-mds-myfs-a-5dbb7ff586-sbk79   1/1       Running   0          57s
rook-ceph-mds-myfs-b-6db4f4c74b-kqc5q   1/1       Running   0          57s

```

## [Rook Toolbox](https://rook.io/docs/rook/v0.9/ceph-toolbox.html)

```
# oc create -f toolbox.yaml
# oc -n rook-ceph get pod -l "app=rook-ceph-tools"
NAME                              READY     STATUS    RESTARTS   AGE
rook-ceph-tools-98f57449f-7cz77   1/1       Running   0          2m

# oc rsh -n rook-ceph rook-ceph-tools-98f57449f-7cz77 
sh-4.2# ceph status
  cluster:
    id:     93ac9782-4def-4825-ace9-cbead4511362
    health: HEALTH_OK
 
  services:
    mon: 3 daemons, quorum c,b,a
    mgr: a(active)
    mds: myfs-1/1/1 up  {0=myfs-b=up:active}, 1 up:standby-replay
    osd: 3 osds: 3 up, 3 in
 
  data:
    pools:   2 pools, 200 pgs
    objects: 22  objects, 2.2 KiB
    usage:   20 GiB used, 280 GiB / 300 GiB avail
    pgs:     200 active+clean
 
  io:
    client:   1.2 KiB/s rd, 2 op/s rd, 0 op/s wr


```

## [External Provisioner](https://mojo.redhat.com/docs/DOC-1189365)

```
# oc rsh rook-ceph-tools-98f57449f-7cz77 bash -c 'ceph auth get-key client.admin' > /tmp/secret
# oc create secret generic ceph-secret-admin --from-file=/tmp/secret
# cd
# go get -d github.com/openshift/external-storage
# cd /root/go/src/github.com/openshift/external-storage/ceph/cephfs/deploy
### use 3-11 branch: PROBLEM with rbac ... need access to endpoints
### https://bugzilla.redhat.com/show_bug.cgi?id=1672750
### git checkout release-3.11
### git log --oneline -1
04aa20d Merge pull request #6 from tsmetana/release-3.11-spec-fix

# git checkout master
# git log --oneline -1
b6215a3 Update EFS ClusterRole with hostmount-anyuid (#12)


# export NAMESPACE=rook-ceph
# sed -r -i "s/namespace: [^ ]+/namespace: $NAMESPACE/g" ./rbac/*.yaml
# oc create -f ./rbac
# oc get pod -l app=cephfs-provisioner  -n rook-ceph
NAME                                  READY     STATUS    RESTARTS   AGE
cephfs-provisioner-7cf79878bd-666zb   1/1       Running   0          51s

### https://bugzilla.redhat.com/show_bug.cgi?id=1586035
# oc adm policy add-scc-to-user anyuid -z cephfs-provisioner

# oc get svc -l app=rook-ceph-mon
NAME              TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
rook-ceph-mon-a   ClusterIP   172.27.33.12    <none>        6790/TCP   48m
rook-ceph-mon-b   ClusterIP   172.27.18.205   <none>        6790/TCP   48m
rook-ceph-mon-c   ClusterIP   172.26.34.176   <none>        6790/TCP   48m

# git diff ../example/class.yaml
diff --git a/ceph/cephfs/example/class.yaml b/ceph/cephfs/example/class.yaml
index 9a16a79..a4a573b 100644
--- a/ceph/cephfs/example/class.yaml
+++ b/ceph/cephfs/example/class.yaml
@@ -4,9 +4,9 @@ metadata:
   name: cephfs
 provisioner: ceph.com/cephfs
 parameters:
-    monitors: 172.24.0.6:6789
+    monitors: 172.27.33.12:6790
     adminId: admin
     adminSecretName: ceph-secret-admin
-    adminSecretNamespace: "kube-system"
+    adminSecretNamespace: "rook-ceph"
     claimRoot: /pvc-volumes

# oc create -f ../example/class.yaml
# oc get sc
NAME            PROVISIONER             AGE
cephfs          ceph.com/cephfs         22s
gp2 (default)   kubernetes.io/aws-ebs   3h

# oc create -f ../example/claim.yaml 
# oc get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS    CLAIM              STORAGECLASS   REASON    AGE
pvc-86a321db-2975-11e9-9235-025ec4c47606   1Gi        RWX            Delete           Bound     rook-ceph/claim1   cephfs                   3s

```

How to use the external provisioner in another namespace?

## [Block Storage](https://rook.io/docs/rook/v0.9/ceph-block.html)
```
# kubectl create -f storageclass.yaml
# oc get sc rook-ceph-block
NAME              PROVISIONER          AGE
rook-ceph-block   ceph.rook.io/block   2m

# oc new-project ttt
# oc process -f https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/pvc_template.yaml -p PVC_NAME=claim1 -p STORAGE_CLASS_NAME=rook-ceph-block | oc create -f -
persistentvolumeclaim/claim1 created
root@ip-172-31-19-126: ~/go/src/github.com/rook/rook/cluster/examples/kubernetes/ceph # oc get pvc
NAME      STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS      AGE
claim1    Bound     pvc-64d1ab33-2af0-11e9-bbcf-0201ad0bb47e   3Gi        RWO            rook-ceph-block   4s


```

## [Object Storage](https://rook.io/docs/rook/v0.9/ceph-object.html)

```
### https://rook.io/docs/rook/v0.9/openshift.html
# git diff object.yaml
...
     # The port that RGW pods will listen on (http)
-    port: 80
+    port: 8080
...

# kubectl create -f object.yaml
# oc get pod -l app=rook-ceph-rgw -n rook-ceph
NAME                                      READY     STATUS    RESTARTS   AGE
rook-ceph-rgw-my-store-7488dc696b-pl28j   1/1       Running   0          58s

### Create the object store user
# kubectl create -f object-user.yaml

# kubectl -n rook-ceph get secret rook-ceph-object-user-my-store-my-user -o yaml | grep AccessKey | awk '{print $2}' | base64 --decode
W4TLO9OBDHDAYB5DJDKP
# kubectl -n rook-ceph get secret rook-ceph-object-user-my-store-my-user -o yaml | grep SecretKey | awk '{print $2}' | base64 --decode
T8hz7zBU9Pxvj2xRiRnvHGVSTxcwDFXyt2CX1koB

# kubectl -n rook-ceph get svc rook-ceph-rgw-my-store
NAME                     TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
rook-ceph-rgw-my-store   ClusterIP   172.24.238.53   <none>        8080/TCP   59m

### https://github.com/s3tools/s3cmd/blob/master/INSTALL
# yum install -y s3cmd
# s3cmd --version
s3cmd version 2.0.2

export AWS_HOST=rook-ceph-rgw-my-store.rook-ceph
export AWS_ENDPOINT=172.24.238.53:8080
export AWS_ACCESS_KEY_ID=W4TLO9OBDHDAYB5DJDKP
export AWS_SECRET_ACCESS_KEY=T8hz7zBU9Pxvj2xRiRnvHGVSTxcwDFXyt2CX1koB

# s3cmd mb --no-ssl --host=${AWS_HOST} --host-bucket=  s3://rookbucket
ERROR: [Errno -2] Name or service not known
ERROR: Connection Error: Error resolving a server hostname.
Please check the servers address specified in 'host_base', 'host_bucket', 'cloudfront_host', 'website_endpoint'

### if i use the svc dns + port, then
# s3cmd ls --no-ssl --host=${AWS_HOST}.svc.cluster.local:8080 --access_key=W4TLO9OBDHDAYB5DJDKP --secret_key=T8hz7zBU9Pxvj2xRiRnvHGVSTxcwDFXyt2CX1koB
ERROR: S3 error: 403 (InvalidAccessKeyId)

# oc logs rook-ceph-rgw-my-store-7488dc696b-pl28j
...
2019-02-07 20:43:26.200 7f140da92700  1 ====== starting new request req=0x7f140da89850 =====
2019-02-07 20:43:26.202 7f140da92700  1 ====== req done req=0x7f140da89850 op status=0 http_status=403 ======
2019-02-07 20:43:26.202 7f140da92700  1 civetweb: 0x55bfbff92000: 172.20.0.1 - - [07/Feb/2019:20:43:26 +0000] "GET / HTTP/1.1" 403 399 - -
2019-02-07 20:43:30.828 7f1430dac700  0 WARNING: RGWRados::log_usage(): user name empty (bucket=), skipping


```

Blocked by [rook/issues/2627](https://github.com/rook/rook/issues/2627). Redo on 20190211, it seems working (NO idea of what happened last week).
_Hit the issue (403) again later this afternoon. Very strange._

```
# s3cmd mb --no-ssl --host=${AWS_ENDPOINT} --host-bucket=  s3://rookbucket
Bucket 's3://rookbucket/' created

###
# oc logs rook-ceph-rgw-my-store-7488dc696b-dxl8b
...
2019-02-11 14:25:08.532 7fae27a52700  1 ====== starting new request req=0x7fae27a49850 =====
2019-02-11 14:25:08.533 7fae27a52700  1 ====== req done req=0x7fae27a49850 op status=0 http_status=404 ======
2019-02-11 14:25:08.533 7fae27a52700  1 civetweb: 0x55b7135be000: 172.20.0.1 - - [11/Feb/2019:14:25:08 +0000] "GET /rookbucket/?location HTTP/1.1" 404 428 - -
2019-02-11 14:25:08.535 7fae27a52700  1 ====== starting new request req=0x7fae27a49850 =====
2019-02-11 14:25:08.543 7fae27a52700  1 ====== req done req=0x7fae27a49850 op status=0 http_status=200 ======
2019-02-11 14:25:08.543 7fae27a52700  1 civetweb: 0x55b7135be000: 172.20.0.1 - - [11/Feb/2019:14:25:08 +0000] "PUT /rookbucket/ HTTP/1.1" 200 143 - -

# s3cmd ls --no-ssl --host=${AWS_HOST}.svc.cluster.local:8080 
2019-02-11 14:25  s3://rookbucket

# oc rsh rook-ceph-tools-98f57449f-8dlw9 
sh-4.2# radosgw-admin user list
[
    "my-user"
]

### Many thanks to Travis Nielsen
### http://docs.ceph.com/docs/mimic/radosgw/admin/#get-user-info
sh-4.2# radosgw-admin user info --uid=my-user

# echo "Hello Rook" > /tmp/rookObj
# s3cmd put /tmp/rookObj --no-ssl --host=${AWS_HOST}.svc.cluster.local:8080 --host-bucket=  s3://rookbucket
upload: '/tmp/rookObj' -> 's3://rookbucket/rookObj'  [1 of 1]
 11 of 11   100% in    0s   242.38 B/s  done
# s3cmd get s3://rookbucket/rookObj /tmp/rookObj-download --no-ssl --host=${AWS_HOST}.svc.cluster.local:8080 --host-bucket=
download: 's3://rookbucket/rookObj' -> '/tmp/rookObj-download'  [1 of 1]
 11 of 11   100% in    0s   266.81 B/s  done
root@ip-172-31-10-252: ~/go/src/github.com/rook/rook/cluster/examples/kubernetes/ceph # cat /tmp/rookObj-download
Hello Rook

```

Access External to the Cluster:

```
### The following steps are different from the ones described at https://rook.io/docs/rook/v0.9/ceph-object.html
### because we have a working subdomain for apps
# oc expose svc rook-ceph-rgw-my-store
route.route.openshift.io/rook-ceph-rgw-my-store exposed
# oc get route
NAME                     HOST/PORT                                                   PATH      SERVICES                 PORT      TERMINATION   WILDCARD
rook-ceph-rgw-my-store   rook-ceph-rgw-my-store-rook-ceph.apps.54.213.79.55.xip.io             rook-ceph-rgw-my-store   http                    None

### tested with a server out of the OCP cluster network
$ export AWS_HOST=rook-ceph-rgw-my-store-rook-ceph.apps.54.213.79.55.xip.io
$ export AWS_ACCESS_KEY_ID=PNU15E8Z7H92HYN3K7Y4
$ export AWS_SECRET_ACCESS_KEY=IYfLy7vLEC3P1D5PpZpSMViHFRON5aBLOcjP6VnD

$ s3cmd ls --no-ssl --host=${AWS_HOST} 
2019-02-11 14:25  s3://rookbucket
2019-02-11 15:22  s3://rookbucket1
2019-02-11 15:41  s3://rookbucket2
```

Question: It seems that one ceph cluster supports to provide only one storage solution of shared-fs, object or block storage.
We have several conflicting cases:

* block and object: object 403.
* object and fs: 

```
# oc logs cephfs-provisioner-7cf79878bd-2nxgk
...
E0211 17:44:35.884379       1 cephfs-provisioner.go:158] failed to provision share "kubernetes-dynamic-pvc-b26da0ef-2e24-11e9-ba98-0a58ac170008" for "kubernetes-dynamic-user-b26da125-2e24-11e9-ba98-0a58ac170008", err: exit status 1, output: Traceback (most recent call last):
  File "/lib64/python2.7/site.py", line 556, in <module>
    main()
  File "/lib64/python2.7/site.py", line 538, in main
    known_paths = addusersitepackages(known_paths)
  File "/lib64/python2.7/site.py", line 266, in addusersitepackages
    user_site = getusersitepackages()
  File "/lib64/python2.7/site.py", line 241, in getusersitepackages
    user_base = getuserbase() # this will also set USER_BASE
  File "/lib64/python2.7/site.py", line 231, in getuserbase
    USER_BASE = get_config_var('userbase')
  File "/lib64/python2.7/sysconfig.py", line 516, in get_config_var
    return get_config_vars().get(name)
  File "/lib64/python2.7/sysconfig.py", line 473, in get_config_vars
    _CONFIG_VARS['userbase'] = _getuserbase()
  File "/lib64/python2.7/sysconfig.py", line 187, in _getuserbase
    return env_base if env_base else joinuser("~", ".local")
  File "/lib64/python2.7/sysconfig.py", line 173, in joinuser
    return os.path.expanduser(os.path.join(*args))
  File "/lib64/python2.7/posixpath.py", line 269, in expanduser
    userhome = pwd.getpwuid(os.getuid()).pw_dir
KeyError: 'getpwuid(): uid not found: 1000320000'

```

However, Travis Nielson told me (20190211) that "Yes, block, object, and file can all be supported by the same rook-ceph cluster".

Updated 20190213: On OCP 4.0, all three stoarge services work at the same time. First time to me.

on OCP 4.0: Since we do not have network access on the jump node to svc `rook-ceph-rgw-my-store` or pod's (ip and port) `172.30.178.33:8080`, we need to access ceph object storage via the exposed svc via route:

```
# oc expose svc rook-ceph-rgw-my-store
route.route.openshift.io/rook-ceph-rgw-my-store exposed
# oc get routes.route.openshift.io 
NAME                     HOST/PORT                                                                     PATH   SERVICES                 PORT   TERMINATION   WILDCARD
rook-ceph-rgw-my-store   rook-ceph-rgw-my-store-rook-ceph.apps.hongkliu3.qe.devcluster.openshift.com          rook-ceph-rgw-my-store   http                 None

# s3cmd mb --no-ssl --host=rook-ceph-rgw-my-store-rook-ceph.apps.hongkliu3.qe.devcluster.openshift.com --host-bucket=  s3://rookbucket
Bucket 's3://rookbucket/' created

# s3cmd ls --no-ssl --host=rook-ceph-rgw-my-store-rook-ceph.apps.hongkliu3.qe.devcluster.openshift.com
2019-02-13 17:28  s3://rookbucket

```

OR, use `s3cmd` in a pod: In this case, we can use route, svc, and pod's IP.

```
# oc new-project test
# oc create -f https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/dc_mycentos.yaml
# oc get pod
NAME              READY   STATUS      RESTARTS   AGE
centos-1-95wl2    1/1     Running     0          15s
centos-1-deploy   0/1     Completed   0          24s

# oc rsh centos-1-95wl2
sh-4.2$ s3cmd ls --no-ssl --host=rook-ceph-rgw-my-store-rook-ceph.apps.hongkliu3.qe.devcluster.openshift.com --access_key=FGNP7GRM5RLL1Q8DY9VE --secret_key=e4MsRHChLJtJy5OfgCH18MO9gYoUZEXp8Ro6DrmP
2019-02-13 17:28  s3://rookbucket
$ s3cmd ls --no-ssl --host=172.30.178.33:8080 --access_key=FGNP7GRM5RLL1Q8DY9VE --secret_key=e4MsRHChLJtJy5OfgCH18MO9gYoUZEXp8Ro6DrmP
2019-02-13 17:28  s3://rookbucket
$ s3cmd ls --no-ssl --host=rook-ceph-rgw-my-store.rook-ceph.svc.cluster.local:8080 --access_key=FGNP7GRM5RLL1Q8DY9VE --secret_key=e4MsRHChLJtJy5OfgCH18MO9gYoUZEXp8Ro6DrmP
2019-02-13 17:28  s3://rookbucket
```

OR install `s3cmd in the tool-box pod`:

```
# oc project rook-ceph
# oc rsh rook-ceph-tools-576bd57b66-xr8h8 
sh-4.2# yum install -y s3cmd
sh-4.2# s3cmd --version
s3cmd version 2.0.2
sh-4.2# s3cmd ls --no-ssl --host=rook-ceph-rgw-my-store.rook-ceph.svc.cluster.local:8080 --access_key=FGNP7GRM5RLL1Q8DY9VE --secret_key=e4MsRHChLJtJy5OfgCH18MO9gYoUZEXp8Ro6DrmP
2019-02-13 17:28  s3://rookbucket
```

Created [[FRE]issues/2648](https://github.com/rook/rook/issues/2648).

## Useful commands on ceph
TODO