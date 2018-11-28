# istio

* [doc@istio](https://istio.io/docs/concepts/what-is-istio/)


## install on OCP

[Steps](https://docs.openshift.com/container-platform/3.11/servicemesh-install/servicemesh-install.html):

```bash
# on master
# cd /etc/origin/master/
# vi master-config.patch
# cp -p master-config.yaml master-config.yaml.prepatch
# oc ex config patch master-config.yaml.prepatch -p "$(cat master-config.patch)" > master-config.yaml
# /usr/local/bin/master-restart api && /usr/local/bin/master-restart controllers

### UPDATING THE NODE CONFIGURATION
### https://www.elastic.co/guide/en/elasticsearch/reference/current/vm-max-map-count.html
# oc get nodes --no-headers | cut -f1 -d" " | while read i; do ssh -n "$i" 'echo "vm.max_map_count = 262144" > /etc/sysctl.d/99-elasticsearch.conf'; done
# oc get nodes --no-headers | cut -f1 -d" " | while read i; do ssh -n "$i" 'sysctl -w vm.max_map_count=262144'; done

```


```bash
### no need to create file `istio-installation.yaml`. will use `cr-full.yaml` in the repo
# git clone https://github.com/Maistra/openshift-ansible.git
# cd openshift-ansible/istio
### branch maistra-0.4 has the version matching in the doc
# git checkout maistra-0.4
# oc new-project istio-operator
# oc new-app -f ./istio_product_operator_template.yaml --param=OPENSHIFT_ISTIO_MASTER_PUBLIC_URL=https://ec2-54-203-156-70.us-west-2.compute.amazonaws.com:8443

# oc get pod
NAME                              READY     STATUS    RESTARTS   AGE
istio-operator-8684f8c749-xdz5l   1/1       Running   0          30m

# oc logs istio-operator-8684f8c749-xdz5l
time="2018-11-27T19:47:00Z" level=info msg="Go Version: go1.9.4"
time="2018-11-27T19:47:00Z" level=info msg="Go OS/Arch: linux/amd64"
time="2018-11-27T19:47:00Z" level=info msg="operator-sdk Version: 0.0.5+git"
time="2018-11-27T19:47:01Z" level=info msg="Metrics service istio-operator created"
time="2018-11-27T19:47:01Z" level=info msg="Watching resource istio.openshift.com/v1alpha1, kind Installation, namespace istio-operator, resyncPeriod 0"

```

```bash
# oc create -f cr-full.yaml -n istio-operator
# oc logs istio-operator-8684f8c749-xdz5l
...
time="2018-11-27T19:50:11Z" level=info msg="Installing istio for Installation istio-installation"


# oc get pod -n istio-system 
NAME                                          READY     STATUS      RESTARTS   AGE
openshift-ansible-istio-installer-job-cjg5c   1/1       Running     0          1m

### we can check the logs of the above pod to see the process of installation via ansible-playbook
### after several minutes

# oc get pod -n istio-system 
NAME                                          READY     STATUS      RESTARTS   AGE
elasticsearch-0                               1/1       Running     0          26m
grafana-6887dd6bd6-jm2vv                      1/1       Running     0          26m
istio-citadel-86557996bc-n8jkl                1/1       Running     0          27m
istio-egressgateway-5dd7cd5b59-j87vn          1/1       Running     0          27m
istio-galley-69b967cdbb-wxsq5                 1/1       Running     0          27m
istio-ingressgateway-5b77b4687b-5c9nv         1/1       Running     0          27m
istio-pilot-6db75d9665-g4v4t                  2/2       Running     0          27m
istio-policy-59c987f97d-5v8fh                 2/2       Running     0          27m
istio-sidecar-injector-69b9599456-sdvdb       1/1       Running     0          27m
istio-telemetry-899657c5c-667fm               2/2       Running     0          27m
jaeger-agent-dbsd4                            1/1       Running     0          25m
jaeger-agent-m5hhz                            1/1       Running     0          25m
jaeger-collector-5c94f596cc-v2t87             1/1       Running     0          25m
jaeger-query-96dc669cc-xb55g                  1/1       Running     0          25m
kiali-7795bff985-phnfr                        1/1       Running     0          25m
openshift-ansible-istio-installer-job-cjg5c   0/1       Completed   0          28m
prometheus-76db5fddd5-lkdgx                   1/1       Running     0          27m

# oc get pod -n devex
NAME                          READY     STATUS    RESTARTS   AGE
configmapcontroller-1-sr5nw   1/1       Running   0          27m
launcher-backend-2-cgt48      1/1       Running   0          26m
launcher-frontend-2-lsnvd     1/1       Running   0          26m

```

Observation:

* `istio-statsd-prom-bridge-7f44bb5ddb-vvtmm` is not there.
* 2 jaeger-agent out of 4 desired

```bash
# oc get pod -o wide | grep jaeger-agent
jaeger-agent-dbsd4                            1/1       Running     0          33m       172.31.32.71   ip-172-31-32-71.us-west-2.compute.internal   <none>
jaeger-agent-m5hhz                            1/1       Running     0          33m       172.31.15.31   ip-172-31-15-31.us-west-2.compute.internal   <none>

# oc get ds
NAME           DESIRED   CURRENT   READY     UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
jaeger-agent   4         2         2         2            2           <none>          33m
root@ip-172-31-58-23: ~/abc/openshift-ansible/istio # oc get node
NAME                                         STATUS    ROLES     AGE       VERSION
ip-172-31-13-1.us-west-2.compute.internal    Ready     infra     4h        v1.11.0+d4cacc0
ip-172-31-15-31.us-west-2.compute.internal   Ready     compute   4h        v1.11.0+d4cacc0
ip-172-31-32-71.us-west-2.compute.internal   Ready     compute   4h        v1.11.0+d4cacc0
ip-172-31-58-23.us-west-2.compute.internal   Ready     master    4h        v1.11.0+d4cacc0


```

After installing bookinfo project,

```bash
# curl -o /dev/null -s -w "%{http_code}\n" http://$GATEWAY_URL/productpage
200


```

In Step `ADD DEFAULT DESTINATION RULES`: how to tell *If you did not enable mutual TLS*?

Blocked here, need more doc reading ...
