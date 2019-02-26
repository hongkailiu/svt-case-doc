# Operator

* [operator-framework](https://github.com/operator-framework)
* [introducing-operator-framework](https://www.redhat.com/en/blog/introducing-operator-framework-building-apps-kubernetes?sc_cid=701f2000000tucqAAA&src=fridayfive4email)
* [Introduce OpenShift to Operators](https://thenewstack.io/coreos-says-red-hat-will-help-introduce-openshift-to-operators/)
* [operator with helm](https://blog.openshift.com/make-a-kubernetes-operator-in-15-minutes-with-helm/)
* [getting-started](https://github.com/operator-framework/getting-started)

## operator sdk

### [Installation](https://github.com/operator-framework/operator-sdk#quick-start)

```sh
###prerequisites: https://github.com/operator-framework/operator-sdk#prerequisites
$ git --version
$ go version
$ kubectl version
$ docker version
### install dep: https://golang.github.io/dep/docs/installation.html#install-from-source
$ dep version

###install operator sdk
$ echo ${GOPATH}
/home/fedora/repo/go
$ operator-sdk --version
operator-sdk version 0.0.6+git

```

### Use operator sdk
Follow [operator-sdk#quick-start](https://github.com/operator-framework/operator-sdk#quick-start)

```sh
### create operator project
$ go get github.com/hongkailiu/operators
$ cd $GOPATH/src/github.com/hongkailiu/operators
$ operator-sdk new app-operator --api-version=app.example.com/v1alpha1 --kind=App --skip-git-init
$ cd app-operator/
###optional
###exclude vendor folder from src
$ echo "vendor/" >> .gitignore
###this can be recovered by
$ dep ensure
### check the generated files: https://github.com/operator-framework/operator-sdk/blob/master/doc/user-guide.md
$ git add .
$ git status

### generate deploy/operator.yaml and build `app-operator` docker image
$ operator-sdk build docker.io/hongkailiu/app-operator
$ docker images | grep docker.io/hongkailiu/app-operator
docker.io/hongkailiu/app-operator            latest              c000909e37f6        About a minute ago   38.8 MB

$ docker login docker.io
$ docker push docker.io/hongkailiu/app-operator

### deploy
$ oc new-project aaa

# Deploy the app-operator
$ kubectl create -f deploy/rbac.yaml
$ kubectl create -f deploy/crd.yaml
$ kubectl create -f deploy/operator.yaml

# By default, creating a custom resource (App) triggers the app-operator to deploy a busybox pod
$ kubectl create -f deploy/cr.yaml

$ oc get all
NAME                                READY     STATUS    RESTARTS   AGE
pod/app-operator-59fcd6dc8f-4vnxn   1/1       Running   0          1m
pod/busy-box                        1/1       Running   0          40s

NAME                   TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)     AGE
service/app-operator   ClusterIP   172.24.148.144   <none>        60000/TCP   1m

NAME                           DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/app-operator   1         1         1            1           1m

NAME                                      DESIRED   CURRENT   READY     AGE
replicaset.apps/app-operator-59fcd6dc8f   1         1         1         1m

```

Observations:

* the operator container: the program starts with [the main function](https://github.com/hongkailiu/operators/blob/master/app-operator/cmd/app-operator/main.go#L23) and we can check its log by

```sh
$ oc logs app-operator-59fcd6dc8f-4vnxn
```

* it handles the events of resource via [the event handler](https://github.com/hongkailiu/operators/blob/master/app-operator/pkg/stub/handler.go#L24)

### Define our own handler for svt-go app
Follow [user-guide](https://github.com/operator-framework/operator-sdk/blob/master/doc/user-guide.md)

Function:
* pod for k8s deployment can be modified as required.
* pod name list will be stored in the CR.

```sh
$ operator-sdk new svt-go-operator --api-version=app.example.com/v1alpha1 --kind=SVTGo
### then edit it as the above user guide
$ operator-sdk generate k8s ##need only once after editting `types.go`
$ operator-sdk build docker.io/hongkailiu/svt-go-operator:a003
$ docker push docker.io/hongkailiu/svt-go-operator:a003
### git-push the change on `deploy/operator.yaml` back to git-repo
```

Demo

```sh
$ cd /home/fedora/repo/go/src/github.com/hongkailiu/operators/svt-go-operator
$ oc new-project ttt
$ kubectl create -f deploy/crd.yaml ###need only once

$ kubectl create -f deploy/rbac.yaml
$ kubectl create -f deploy/operator.yaml

$ oc get pod
NAME                              READY     STATUS    RESTARTS   AGE
svt-go-operator-c4cbdc9cd-6rbxj   1/1       Running   0          12s

$ kubectl create -f deploy/cr.yaml
$ oc get svtgo
NAME      AGE
example   29s

$ oc get pod
NAME                              READY     STATUS    RESTARTS   AGE
example-976d9849f-6hxwg           1/1       Running   0          2m
svt-go-operator-c4cbdc9cd-6rbxj   1/1       Running   0          6m


$ oc get svtgo example -o yaml
apiVersion: app.example.com/v1alpha1
kind: SVTGo
metadata:
  creationTimestamp: 2018-09-07T21:10:32Z
  generation: 1
  name: example
  namespace: ttt
  resourceVersion: "61544"
  selfLink: /apis/app.example.com/v1alpha1/namespaces/ttt/svtgos/example
  uid: 74714fe5-b2e2-11e8-98d2-025a295eb400
spec:
  size: 1
status:
  nodes:
  - example-976d9849f-6hxwg

###modify the size

vi deploy/cr.yaml
...
spec:
  size: 2


$ kubectl apply -f deploy/cr.yaml
$ oc get pod
NAME                              READY     STATUS    RESTARTS   AGE
example-976d9849f-58m26           1/1       Running   0          27s
example-976d9849f-6hxwg           1/1       Running   0          2m
svt-go-operator-c4cbdc9cd-6rbxj   1/1       Running   0          6m

$ oc get svtgo example -o yaml
```

[test-framework](https://github.com/operator-framework/operator-sdk/blob/master/doc/test-framework/writing-e2e-tests.md)

## [Operator Lifecycle Manager](https://github.com/operator-framework/operator-lifecycle-manager)

OLM provides cli tool to manager operator. The UI functionality is from `Tectonic Console` which
has been integrated to OC console, `cluster console`.

[Install](https://github.com/operator-framework/operator-lifecycle-manager/blob/master/Documentation/install/install.md):

```bash
$ ansible-playbook -i build/output/flexy/inv/2.file ${ansible_repo_path}/playbooks/olm/config.yml

# oc get all -n operator-lifecycle-manager
NAME                                   READY     STATUS    RESTARTS   AGE
pod/catalog-operator-67679484f-zrqmm   1/1       Running   0          2m
pod/olm-operator-c849d4674-s7mvg       1/1       Running   0          2m

NAME                               DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/catalog-operator   1         1         1            1           2m
deployment.apps/olm-operator       1         1         1            1           2m

NAME                                         DESIRED   CURRENT   READY     AGE
replicaset.apps/catalog-operator-67679484f   1         1         1         2m
replicaset.apps/olm-operator-c849d4674       1         1         1         2m

NAME                                                     NAME                  TYPE       PUBLISHER   AGE
catalogsource.operators.coreos.com/certified-operators   Certified Operators   internal   Red Hat     2m
catalogsource.operators.coreos.com/rh-operators          Red Hat Operators     internal   Red Hat     2m

```

Deploy an operator with OLM:

```bash
$ git clone https://github.com/hongkailiu/helm-app-operator-kit.git
$ cd helm-app-operator-kit/
$ git checkout svt-go

$ oc new-project ttt
$ kubectl create -f helm-app-operator/deploy/olm-catalog/crd.yaml
###https://github.com/operator-framework/getting-started/issues/21
$ head -n 1 helm-app-operator/deploy/olm-catalog/csv.yaml
apiVersion: operators.coreos.com/v1alpha1
$ kubectl create -n ttt -f helm-app-operator/deploy/olm-catalog/csv.yaml
$ kubectl create -n ttt -f helm-app-operator/deploy/cr.yaml

### Check the Web console ... We can see SVT app there.

### check the pod
$ oc get pod
### change the number of replicas
$ vi helm-app-operator/deploy/cr.yaml
$ kubectl apply -n ttt -f helm-app-operator/deploy/cr.yaml

### clean up
$ kubectl delete -n ttt -f helm-app-operator/deploy/cr.yaml
$ kubectl delete -n ttt -f helm-app-operator/deploy/olm-catalog/csv.yaml

$ oc delete project ttt

$ kubectl delete -f helm-app-operator/deploy/crd.yaml

```

TODO: Understand [package.yaml](https://github.com/operator-framework/helm-app-operator-kit/blob/master/helm-app-operator/deploy/olm-catalog/package.yaml), [InstallPlan, CatalogSource, Subscription](https://github.com/operator-framework/operator-lifecycle-manager/blob/master/Documentation/design/philosophy.md#installplan).
No doc about how to use them.


## [Helm app operator kit](https://github.com/operator-framework/helm-app-operator-kit)

```bash
### generate the helm pkg if have not done so before
$ git clone https://github.com/hongkailiu/charts.git
$ cd charts
$ helm package stable/svt-go
$ # readlink ~/charts/svt-go-0.1.0.tgz  -f
/root/charts/svt-go-0.1.0.tgz
### Or download from: https://github.com/cduser/svt-release/raw/helm_svt_go_0.1.0/svt-go-0.1.0.tgz

### clone the fork
### Using master branch is OK
$ git clone https://github.com/hongkailiu/helm-app-operator-kit.git
$ cd helm-app-operator-kit/
### need docker 17.05+ for multi-stage:
### https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-builds
### buildah supports it recently: https://github.com/containers/buildah/issues/440
### WIP for operator sdk to use this feature: https://github.com/operator-framework/operator-sdk/pull/563
### get a centos for building the image
### https://docs.docker.com/install/linux/docker-ce/centos/#install-docker-ce-1

###https://github.com/operator-framework/helm-app-operator-kit/pull/28
###Note that the command example is not updated accordingly (still using http...tar.gz file)
$ mkdir chart
$ tar -xvzf ./svt-go-0.1.0.tgz --strip-components=1 -C ./chart
$ docker build   --build-arg HELM_CHART=chart   --build-arg API_VERSION=app.example.com/v1alpha1   --build-arg KIND=SVTGo   -t quay.io/hongkailiu/h-svt-go-operator:v0.0.2 .
$ docker push quay.io/hongkailiu/h-svt-go-operator:v0.0.2

### modify the deploy files
### the changes are pushed to svt-go branch
### Note that the changes on clusterRule, clusterRuleBinding, dc, route in rbac.yaml file

```

Update on 20181010: `buildah` supports [multi-stage builds already from v1.0](https://github.com/containers/buildah/releases):

```
### Tested with a rhel75 ec2 instance where docker is not installed.
# buildah --version
buildah version 1.2 (image-spec 1.0.0, runtime-spec 1.0.0)
# vi /etc/containers/registries.conf
...
[registries.search]
registries = ['registry.access.redhat.com', 'docker.io']
...
# buildah bud --format=docker -f Dockerfile -t quay.io/hongkailiu/h-svt-go-operator:v0.0.3-buildah --build-arg HELM_CHART=chart --build-arg API_VERSION=app.example.com/v1alpha1 --build-arg KIND=SVTGo .
# buildah images
IMAGE ID             IMAGE NAME                                               CREATED AT             SIZE
a4afc24299ee         docker.io/library/golang:1.10                            Sep 5, 2018 11:16      749 MB
94627dfbdf19         docker.io/library/alpine:3.6                             Sep 11, 2018 22:19     4.29 MB
d2d390e91a00         quay.io/hongkailiu/h-svt-go-operator:v0.0.3-buildah      Oct 10, 2018 18:33     86.2 MB
# buildah push --creds=hongkailiu d2d390e91a00 docker://quay.io/hongkailiu/h-svt-go-operator:v0.0.3-buildah
```

Demo:

```bash
$ git clone https://github.com/hongkailiu/helm-app-operator-kit.git
$ cd helm-app-operator-kit/
$ git checkout svt-go

$ oc new-project ttt
$ kubectl create -f helm-app-operator/deploy/crd.yaml
### has to be oc cli here if it contains clusterRoleBinding
$ oc create -n ttt -f helm-app-operator/deploy/rbac.yaml
$ kubectl create -n ttt -f helm-app-operator/deploy/operator.yaml
$ kubectl create -n ttt -f helm-app-operator/deploy/cr.yaml

### check the pod
$ oc get pod
### change the number of replicas
$ vi helm-app-operator/deploy/cr.yaml
$ kubectl apply -n ttt -f helm-app-operator/deploy/cr.yaml

### clean up
$ kubectl delete -n ttt -f helm-app-operator/deploy/cr.yaml
$ kubectl delete -n ttt -f helm-app-operator/deploy/operator.yaml
$ oc delete -n ttt -f helm-app-operator/deploy/rbac.yaml

$ oc delete project ttt

$ kubectl delete -f helm-app-operator/deploy/crd.yaml


```

## Openshift monitoring

[Installation](https://github.com/openshift/openshift-ansible/tree/master/playbooks/openshift-monitoring)

```sh
$ ansible-playbook -i aaa/ openshift-ansible/playbooks/openshift-monitoring/config.yml

# oc project openshift-monitoring
Now using project "openshift-monitoring" on server "https://ip-172-31-20-26.us-west-2.compute.internal:8443".
root@ip-172-31-20-26: ~ # oc get all
NAME                                               READY     STATUS    RESTARTS   AGE
pod/alertmanager-main-0                            3/3       Running   0          2m
pod/alertmanager-main-1                            3/3       Running   0          2m
pod/alertmanager-main-2                            3/3       Running   0          1m
pod/cluster-monitoring-operator-7f956789fc-gr4x5   1/1       Running   0          5m
pod/grafana-6bd78bcd6d-hbfpq                       2/2       Running   0          4m
pod/kube-state-metrics-58d4dd6b44-9lnf7            3/3       Running   0          1m
pod/prometheus-k8s-0                               4/4       Running   1          3m
pod/prometheus-k8s-1                               4/4       Running   1          2m
pod/prometheus-operator-7fff695789-rcz4m           1/1       Running   0          5m

NAME                                  TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE
service/alertmanager-main             ClusterIP   172.24.248.184   <none>        9094/TCP            2m
service/alertmanager-operated         ClusterIP   None             <none>        9093/TCP,6783/TCP   2m
service/cluster-monitoring-operator   ClusterIP   None             <none>        8080/TCP            4m
service/grafana                       ClusterIP   172.26.74.14     <none>        3000/TCP            4m
service/kube-state-metrics            ClusterIP   None             <none>        8443/TCP,9443/TCP   1m
service/node-exporter                 ClusterIP   None             <none>        9100/TCP            1m
service/prometheus-k8s                ClusterIP   172.25.65.6      <none>        9091/TCP            3m
service/prometheus-operated           ClusterIP   None             <none>        9090/TCP            3m
service/prometheus-operator           ClusterIP   None             <none>        8080/TCP            5m

NAME                           DESIRED   CURRENT   READY     UP-TO-DATE   AVAILABLE   NODE SELECTOR                 AGE
daemonset.apps/node-exporter   0         0         0         0            0           beta.kubernetes.io/os=linux   1m

NAME                                          DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/cluster-monitoring-operator   1         1         1            1           5m
deployment.apps/grafana                       1         1         1            1           4m
deployment.apps/kube-state-metrics            1         1         1            1           1m
deployment.apps/prometheus-operator           1         1         1            1           5m

NAME                                                     DESIRED   CURRENT   READY     AGE
replicaset.apps/cluster-monitoring-operator-7f956789fc   1         1         1         5m
replicaset.apps/grafana-6bd78bcd6d                       1         1         1         4m
replicaset.apps/kube-state-metrics-58d4dd6b44            1         1         1         1m
replicaset.apps/prometheus-operator-7fff695789           1         1         1         5m

NAME                                 DESIRED   CURRENT   AGE
statefulset.apps/alertmanager-main   3         3         2m
statefulset.apps/prometheus-k8s      2         2         3m

NAME                                         HOST/PORT                                                             PATH      SERVICES            PORT      TERMINATION   WILDCARD
route.route.openshift.io/alertmanager-main   alertmanager-main-openshift-monitoring.apps.0822-eoo.qe.rhcloud.com             alertmanager-main   web       reencrypt     None
route.route.openshift.io/grafana             grafana-openshift-monitoring.apps.0822-eoo.qe.rhcloud.com                       grafana             https     reencrypt     None
route.route.openshift.io/prometheus-k8s      prometheus-k8s-openshift-monitoring.apps.0822-eoo.qe.rhcloud.com                prometheus-k8s      web       reencrypt     None

# oc get pvc
NAME                                       STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
alertmanager-main-db-alertmanager-main-0   Bound     pvc-dff44949-a60e-11e8-8dc1-026cee33ed60   2Gi        RWO            gp2            2m
alertmanager-main-db-alertmanager-main-1   Bound     pvc-e928b593-a60e-11e8-8dc1-026cee33ed60   2Gi        RWO            gp2            2m
alertmanager-main-db-alertmanager-main-2   Bound     pvc-f6fd1bb6-a60e-11e8-8dc1-026cee33ed60   2Gi        RWO            gp2            2m
prometheus-k8s-db-prometheus-k8s-0         Bound     pvc-af66d092-a60e-11e8-8dc1-026cee33ed60   50Gi       RWO            gp2            4m
prometheus-k8s-db-prometheus-k8s-1         Bound     pvc-ca971a98-a60e-11e8-8dc1-026cee33ed60   50Gi       RWO            gp2            3m

```

Uninstall:

```sh
# vi aaa/2.file
[OSEv3:vars]
...
openshift_cluster_monitoring_operator_install=false
### then, rerun the above playbook
```

Control the PVC size and sc:
```
###https://github.com/openshift/openshift-ansible/blob/master/roles/openshift_cluster_monitoring_operator/defaults/main.yml#L46-L47
# vi aaa/2.file
[OSEv3:vars]
...
openshift_cluster_monitoring_operator_prometheus_storage_capacity=60Gi
openshift_cluster_monitoring_operator_alertmanager_storage_capacity=6Gi

###No support yet to control the size of PVC via variables
###But we can change the src to achieve that
~/openshift-ansible # git diff
diff --git a/roles/openshift_cluster_monitoring_operator/templates/cluster-monitoring-operator-config.j2 b/roles/openshift_clu
index dbb3120..dc72650 100644
--- a/roles/openshift_cluster_monitoring_operator/templates/cluster-monitoring-operator-config.j2
+++ b/roles/openshift_cluster_monitoring_operator/templates/cluster-monitoring-operator-config.j2
@@ -27,6 +27,7 @@ data:
         cluster: {{ openshift_cluster_monitoring_operator_cluster_id }}
       volumeClaimTemplate:
         spec:
+          storageClassName: {{ openshift_cluster_monitoring_operator_prometheus_storage_class_name }}
           resources:
             requests:
               storage: {{ openshift_cluster_monitoring_operator_prometheus_storage_capacity }}
@@ -40,6 +41,7 @@ data:
 {% endif %}
       volumeClaimTemplate:
         spec:
+          storageClassName: {{ openshift_cluster_monitoring_operator_alertmanager_storage_class_name }}
           resources:
             requests:
               storage: {{ openshift_cluster_monitoring_operator_alertmanager_storage_capacity }}

# vi aaa/2.file
[OSEv3:vars]
...
openshift_cluster_monitoring_operator_prometheus_storage_class_name=glusterfs-storage
openshift_cluster_monitoring_operator_alertmanager_storage_class_name=glusterfs-storage

### Then rerun the playbook

# oc get pvc -n openshift-monitoring
NAME                                       STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS        AGE
alertmanager-main-db-alertmanager-main-0   Bound     pvc-b83923d3-a61d-11e8-8dc1-026cee33ed60   6Gi        RWO            glusterfs-storage   1m
alertmanager-main-db-alertmanager-main-1   Bound     pvc-be637c95-a61d-11e8-8dc1-026cee33ed60   6Gi        RWO            glusterfs-storage   58s
alertmanager-main-db-alertmanager-main-2   Bound     pvc-c4e2ea1b-a61d-11e8-8dc1-026cee33ed60   6Gi        RWO            glusterfs-storage   47s
prometheus-k8s-db-prometheus-k8s-0         Bound     pvc-a586b9da-a61d-11e8-8dc1-026cee33ed60   60Gi       RWO            glusterfs-storage   1m
prometheus-k8s-db-prometheus-k8s-1         Bound     pvc-adc373fe-a61d-11e8-8dc1-026cee33ed60   60Gi       RWO            glusterfs-storage   1m

```

Use grafana via browser: 20180924

```sh
# oc adm policy add-cluster-role-to-user cluster-admin redhat
# oc get route -n openshift-monitoring  | grep grafana
grafana             grafana-openshift-monitoring.apps.0924-cfs.qe.rhcloud.com                       grafana             https     reencrypt     None
### Visit https://grafana-openshift-monitoring.apps.0924-cfs.qe.rhcloud.com
### then login with redhat user (which is an admin)
```


## Openshift metering

[Installation](https://github.com/openshift/openshift-ansible/tree/master/playbooks/openshift-metering)

```sh
$ ansible-playbook -i aaa/ openshift-ansible/playbooks/openshift-metering/config.yml
# oc project openshift-metering
# oc get all
NAME                                      READY     STATUS    RESTARTS   AGE
pod/hdfs-datanode-0                       1/1       Running   0          4m
pod/hdfs-namenode-0                       1/1       Running   0          4m
pod/hive-metastore-0                      1/1       Running   0          4m
pod/hive-server-0                         1/1       Running   0          4m
pod/metering-operator-df67bb6cb-4qt5t     2/2       Running   0          6m
pod/presto-coordinator-78b49dfb5c-pgs79   1/1       Running   0          4m
pod/reporting-operator-5f7fbc9559-vjlgw   1/1       Running   0          4m

NAME                                 TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)               AGE
service/hdfs-datanode                ClusterIP   None             <none>        50010/TCP             4m
service/hdfs-datanode-web            ClusterIP   172.27.204.227   <none>        50075/TCP             4m
service/hdfs-namenode                ClusterIP   None             <none>        8020/TCP              4m
service/hdfs-namenode-proxy          ClusterIP   172.25.34.80     <none>        8020/TCP              4m
service/hdfs-namenode-web            ClusterIP   172.25.69.3      <none>        50070/TCP             4m
service/hive-metastore               ClusterIP   172.25.249.119   <none>        9083/TCP              4m
service/hive-server                  ClusterIP   172.27.221.255   <none>        10000/TCP,10002/TCP   4m
service/presto                       ClusterIP   172.25.142.126   <none>        8080/TCP,8082/TCP     4m
service/reporting-operator           ClusterIP   172.26.55.47     <none>        8080/TCP              4m
service/reporting-operator-metrics   ClusterIP   172.26.121.101   <none>        8082/TCP              4m

NAME                                 DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/metering-operator    1         1         1            1           6m
deployment.apps/presto-coordinator   1         1         1            1           4m
deployment.apps/presto-worker        0         0         0            0           4m
deployment.apps/reporting-operator   1         1         1            1           4m

NAME                                            DESIRED   CURRENT   READY     AGE
replicaset.apps/metering-operator-df67bb6cb     1         1         1         6m
replicaset.apps/presto-coordinator-78b49dfb5c   1         1         1         4m
replicaset.apps/presto-worker-7f95dcbd64        0         0         0         4m
replicaset.apps/reporting-operator-5f7fbc9559   1         1         1         4m

NAME                              DESIRED   CURRENT   AGE
statefulset.apps/hdfs-datanode    1         1         4m
statefulset.apps/hdfs-namenode    1         1         4m
statefulset.apps/hive-metastore   1         1         4m
statefulset.apps/hive-server      1         1         4m

# oc get pvc
NAME                                 STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
hdfs-datanode-data-hdfs-datanode-0   Bound     pvc-d73d0e3a-a61f-11e8-8dc1-026cee33ed60   5Gi        RWO            gp2            4m
hdfs-namenode-data-hdfs-namenode-0   Bound     pvc-d74c9d88-a61f-11e8-8dc1-026cee33ed60   5Gi        RWO            gp2            4m
hive-metastore-db-data               Bound     pvc-d71e7c9e-a61f-11e8-8dc1-026cee33ed60   5Gi        RWO            gp2            4m

```

Uninstall:

```sh
$ ansible-playbook -i aaa/ openshift-ansible/playbooks/openshift-metering/uninstall.yml
```


Control the PVC size and sc:

```sh
### the default config is here:
~/openshift-ansible # grep -irn "metering.openshift.io/v1alpha1" .
./roles/openshift_metering/files/operator/metering.yaml:1:apiVersion: metering.openshift.io/v1alpha1
### we can replace it by setting var openshift_metering_config
### https://github.com/openshift/openshift-ansible/tree/master/roles/openshift_metering
### the syntax: https://github.com/operator-framework/operator-metering/blob/master/manifests/metering-config/custom-storageclass-values.yaml

# mkdir /tmp/openshift_metering_config
# vi /tmp/openshift_metering_config/metering.yaml
### content is here: https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/metering.yaml

### then rerun the playbook with this var file
# ansible-playbook -i aaa/ openshift-ansible/playbooks/openshift-metering/config.yml --extra-vars "@/tmp/openshift_metering_config/metering.yaml"

# oc get pvc
NAME                                 STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS        AGE
hdfs-datanode-data-hdfs-datanode-0   Bound     pvc-dc0220c1-a6d0-11e8-b49c-0279bbe13b54   15Gi       RWO            glusterfs-storage   2m
hdfs-namenode-data-hdfs-namenode-0   Bound     pvc-dc11ccb9-a6d0-11e8-b49c-0279bbe13b54   15Gi       RWO            glusterfs-storage   2m
hive-metastore-db-data               Bound     pvc-dbd5f44c-a6d0-11e8-b49c-0279bbe13b54   15Gi       RWO            glusterfs-storage   2m

```

