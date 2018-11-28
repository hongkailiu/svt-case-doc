# istio

* [doc@istio](https://istio.io/docs/concepts/what-is-istio/)


## install on OCP

[Steps](https://docs.openshift.com/container-platform/3.11/servicemesh-install/servicemesh-install.html):

```bash
# on master
# cd /etc/origin/master/
###content of master-config.patch:
###check the above steps or https://github.com/Maistra/openshift-ansible/blob/maistra-0.4/istio/master-config.patch
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
# cd /tmp/
# git clone https://github.com/Maistra/openshift-ansible.git
# cd openshift-ansible/istio
### branch maistra-0.4 has the version matching in the doc
# git checkout maistra-0.4
# oc new-project istio-operator
# OPENSHIFT_ISTIO_MASTER_PUBLIC_URL=$(grep "masterPublicURL" /etc/origin/master/master-config.yaml | head -n 1 | awk '{print $2}')
# oc new-app -f ./istio_product_operator_template.yaml --param=OPENSHIFT_ISTIO_MASTER_PUBLIC_URL=${OPENSHIFT_ISTIO_MASTER_PUBLIC_URL}

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

Observation: TODO: bz?

* `istio-statsd-prom-bridge-*` is not there.
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

## bookinfo app
[installation](https://docs.openshift.com/container-platform/3.11/servicemesh-install/servicemesh-install.html#installing-bookinfo-application)

```bash
# oc new-project myproject
# oc adm policy add-scc-to-user anyuid -z default -n myproject
# oc adm policy add-scc-to-user privileged -z default -n myproject
# oc apply -n myproject -f https://raw.githubusercontent.com/Maistra/bookinfo/master/bookinfo.yaml
# oc apply -n myproject -f https://raw.githubusercontent.com/Maistra/bookinfo/master/bookinfo-gateway.yaml
### when all pods are running
# oc get pods
NAME                              READY     STATUS    RESTARTS   AGE
details-v1-54b6b58d9c-l4wft       2/2       Running   0          2m
productpage-v1-69b749ff4c-txv2l   2/2       Running   0          2m
ratings-v1-7ffc85d9bf-tphrv       2/2       Running   0          2m
reviews-v1-fcd7cc7b6-mhfmp        2/2       Running   0          2m
reviews-v2-655cc678db-wdbmd       2/2       Running   0          2m
reviews-v3-645d59bdfd-vfprk       2/2       Running   0          2m

# export GATEWAY_URL=$(oc get route -n istio-system istio-ingressgateway -o jsonpath='{.spec.host}')
# curl -o /dev/null -s -w "%{http_code}\n" http://$GATEWAY_URL/productpage
200

### use browser:
# echo  http://$GATEWAY_URL/productpage
http://istio-ingressgateway-istio-system.apps.52.32.1.134.xip.io/productpage

```

In Step `ADD DEFAULT DESTINATION RULES`: how to tell *If you did not enable mutual TLS*?

In the command `oc create -f cr-full.yaml -n istio-operator` above:

```sh
# grep authentication cr-full.yaml -B1
  istio:
    authentication: true

```

`authentication` indicates "Whether to enable mutual authentication". It *seems* that `mutual authentication` is `mutual TLS`.

```
# curl -o destination-rule-all-mtls.yaml https://raw.githubusercontent.com/istio/istio/release-1.0/samples/bookinfo/networking/destination-rule-all-mtls.yaml
# oc apply -f destination-rule-all-mtls.yaml

```



[Install](https://istio.io/docs/setup/kubernetes/download-release/) `istioctl`

```bash
# curl -LO https://github.com/istio/istio/releases/download/1.0.4/istio-1.0.4-linux.tar.gz

# cd ~/bin/
# ln -s ../istio-1.0.4/bin/istioctl istioctl

# istioctl version
Version: 1.0.4
GitRevision: d5cb99f479ad9da88eebb8bb3637b17c323bc50b
User: root@8c2feba0b568
Hub: docker.io/istio
GolangVersion: go1.10.4
BuildStatus: Clean

# istioctl get all
NAME      KIND                                          NAMESPACE   AGE
default   MeshPolicy.authentication.istio.io.v1alpha1               2h

DESTINATION-RULE NAME   HOST          SUBSETS                      NAMESPACE   AGE
details                 details       v1,v2                        myproject   2h
productpage             productpage   v1                           myproject   2h
ratings                 ratings       v1,v2,v2-mysql,v2-mysql-vm   myproject   2h
reviews                 reviews       v1,v2,v3                     myproject   2h

VIRTUAL-SERVICE NAME   GATEWAYS           HOSTS     #HTTP     #TCP      NAMESPACE   AGE
bookinfo               bookinfo-gateway   *             1        0      myproject   2h

GATEWAY NAME       HOSTS     NAMESPACE   AGE
bookinfo-gateway   *         myproject   2h

###the above can be listed by oc command
# oc get crd | grep istio
# oc get virtualservices
# oc get meshpolicies
# oc get gateway
# oc get destinationrule


### HOW CAN I CHECK WHETHER MUTUAL TLS IS ENABLED FOR A SERVICE?
### https://istio.io/help/faq/security/#check-policy
# oc get svc -n devex 
NAME                TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
launcher-backend    ClusterIP   172.26.217.161   <none>        8080/TCP   3h
launcher-frontend   ClusterIP   172.25.154.132   <none>        8080/TCP   3h

# istioctl authn tls-check | grep launcher
launcher-backend.devex.svc.cluster.local:8080                               OK           mTLS       mTLS       default/                                       default/istio-system
launcher-frontend.devex.svc.cluster.local:8080                              OK           mTLS       mTLS       default/                                       default/istio-system


```

## [jaeger](https://www.jaegertracing.io/)

```bash
# 
# export JAEGER_URL=$(oc get route -n istio-system jaeger-query -o jsonpath='{.spec.host}')
# echo "https://${JAEGER_URL}"
https://jaeger-query-istio-system.apps.52.32.1.134.xip.io

```

Observation: 

* no service called `productpage` in the list on the UI.

## prometheus

```bash
# export PROMETHEUS_URL=$(oc get route -n istio-system prometheus -o jsonpath='{.spec.host}')
# echo http://${PROMETHEUS_URL}
http://prometheus-istio-system.apps.52.32.1.134.xip.io

```

Observation:

* in [querying-metrics](https://docs.openshift.com/container-platform/3.11/servicemesh-install/servicemesh-install.html#querying-metrics) session: 
    Step 7 does not work: nothing returned.
    ```bash
    $ oc get prometheus -n istio-system -o jsonpath='{.items[*].spec.metrics[*].name}'
  
    ```

## [kiali](https://www.kiali.io/)

```bash
# oc get route -n istio-system
NAME                   HOST/PORT                                                   PATH      SERVICES               PORT              TERMINATION   WILDCARD
grafana                grafana-istio-system.apps.52.32.1.134.xip.io                          grafana                http                            None
istio-ingressgateway   istio-ingressgateway-istio-system.apps.52.32.1.134.xip.io             istio-ingressgateway   http2                           None
jaeger-query           jaeger-query-istio-system.apps.52.32.1.134.xip.io                     jaeger-query           jaeger-query      edge          None
kiali                  kiali-istio-system.apps.52.32.1.134.xip.io                            kiali                  http-kiali        reencrypt     None
prometheus             prometheus-istio-system.apps.52.32.1.134.xip.io                       prometheus             http-prometheus                 None
tracing                tracing-istio-system.apps.52.32.1.134.xip.io                          tracing                tracing           edge          None

# export KIALI_URL=$(oc get route -n istio-system kiali -o jsonpath='{.spec.host}')
# echo https://${KIALI_URL}
https://kiali-istio-system.apps.52.32.1.134.xip.io
### see the username/password in cr-full.yaml

```

Observation:

* route `istio-ingress` is missing.
* graph for `myproject` has no `istio-system` node or `mongodb` node

## grafana

```bash
# export GRAFANA_URL=$(oc get route -n istio-system grafana -o jsonpath='{.spec.host}')
# echo  http://${GRAFANA_URL}
http://grafana-istio-system.apps.52.32.1.134.xip.io

###Istio Mesh Dashboard
###http://grafana-istio-system.apps.52.32.1.134.xip.io/d/1/istio-mesh-dashboard?refresh=5s&orgId=1
###Istio Workload Dashboard
###http://grafana-istio-system.apps.52.32.1.134.xip.io/d/UbsSZTDik/istio-workload-dashboard?refresh=10s&orgId=1
```

This section works nicely.

## [Red Hat OpenShift Application Runtime Missions](https://docs.openshift.com/container-platform/3.11/servicemesh-install/servicemesh-install.html#rhoar-missions) 
This section is not detailed enough to do test. Leave it as a TODO.




