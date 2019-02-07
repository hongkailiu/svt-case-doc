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
        - name: ROOK_HOSTPATH_REQUIRES_PRIVILEGED
          value: "true"

# oc create -f operator.yaml
### https://github.com/rook/rook/issues/2612

# oc get pod -n rook-ceph-system
NAME                                 READY   STATUS                 RESTARTS   AGE
rook-ceph-agent-6mvrd                0/1     CreateContainerError   0          31m
rook-ceph-agent-lrl8t                0/1     CreateContainerError   0          31m
rook-ceph-agent-x6b94                0/1     CreateContainerError   0          31m
rook-ceph-operator-765b9f645-t68vz   1/1     Running                0          32m
rook-discover-27fwl                  1/1     Running                0          31m
rook-discover-88nsq                  1/1     Running                0          31m
rook-discover-x9nnc                  1/1     Running                0          31m


# oc create -f cluster.yaml

```

Blocked by [issues/2612](https://github.com/rook/rook/issues/2612).

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

# oc rsh rook-ceph-tools-98f57449f-7cz77 
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

TODO: configure ceph to use Additional device

## [External Provisioner](https://mojo.redhat.com/docs/DOC-1189365)

```
# oc rsh rook-ceph-tools-98f57449f-7cz77 bash -c 'ceph auth get-key client.admin' > /tmp/secret
# oc create secret generic ceph-secret-admin --from-file=/tmp/secret
# cd
# go get -d github.com/openshift/external-storage
# cd /root/go/src/github.com/openshift/external-storage/ceph/cephfs/deploy
### use 3-11 branch: PROBLEM with rbac ... need access to endpoints
### https://bugzilla.redhat.com/show_bug.cgi?id=1672750
# git checkout release-3.11
# git log --oneline -1
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


TODO: block storage, object storage
