# istio

## Test steps

Follow the steps: [doc@istio](https://istio.io/docs/concepts/what-is-istio/)

### install on OCP

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

# oc get svc -n istio-system 
NAME                     TYPE           CLUSTER-IP       EXTERNAL-IP                                                               PORT(S)                                                                                                                   AGE
elasticsearch            ClusterIP      172.24.175.51    <none>                                                                    9200/TCP                                                                                                                  8m
elasticsearch-cluster    ClusterIP      172.27.235.80    <none>                                                                    9300/TCP                                                                                                                  8m
grafana                  ClusterIP      172.25.216.3     <none>                                                                    3000/TCP                                                                                                                  8m
istio-citadel            ClusterIP      172.27.84.154    <none>                                                                    8060/TCP,9093/TCP                                                                                                         9m
istio-egressgateway      ClusterIP      172.25.8.77      <none>                                                                    80/TCP,443/TCP                                                                                                            9m
istio-galley             ClusterIP      172.25.157.50    <none>                                                                    443/TCP,9093/TCP                                                                                                          9m
istio-ingressgateway     LoadBalancer   172.25.110.62    ae67d308ef4bc11e898f102fa9e2e24a-539964417.us-west-2.elb.amazonaws.com    80:31380/TCP,443:31390/TCP,31400:31400/TCP,15011:30023/TCP,8060:30574/TCP,853:31654/TCP,15030:32671/TCP,15031:32364/TCP   9m
istio-pilot              ClusterIP      172.27.247.117   <none>                                                                    15010/TCP,15011/TCP,8080/TCP,9093/TCP                                                                                     9m
istio-policy             ClusterIP      172.24.208.110   <none>                                                                    9091/TCP,15004/TCP,9093/TCP                                                                                               9m
istio-sidecar-injector   ClusterIP      172.27.0.188     <none>                                                                    443/TCP                                                                                                                   9m
istio-telemetry          ClusterIP      172.25.23.172    <none>                                                                    9091/TCP,15004/TCP,9093/TCP,42422/TCP                                                                                     9m
jaeger-collector         ClusterIP      172.25.17.221    <none>                                                                    14267/TCP,14268/TCP,9411/TCP                                                                                              7m
jaeger-query             LoadBalancer   172.25.204.146   a216b4dddf4bd11e898f102fa9e2e24a-197988756.us-west-2.elb.amazonaws.com    80:30839/TCP                                                                                                              7m
kiali                    ClusterIP      172.25.214.129   <none>                                                                    20001/TCP                                                                                                                 7m
prometheus               ClusterIP      172.24.91.214    <none>                                                                    9090/TCP                                                                                                                  9m
tracing                  LoadBalancer   172.26.173.190   a21ceb43df4bd11e898f102fa9e2e24a-1195692779.us-west-2.elb.amazonaws.com   80:31899/TCP                                                                                                              7m
zipkin                   ClusterIP      172.24.169.172   <none>                                                                    9411/TCP                                                                                                                  7m


# oc get pod -n devex
NAME                          READY     STATUS    RESTARTS   AGE
configmapcontroller-1-sr5nw   1/1       Running   0          27m
launcher-backend-2-cgt48      1/1       Running   0          26m
launcher-frontend-2-lsnvd     1/1       Running   0          26m

```

_Notice_ that 
* There are 3 services with type `LoadBalancer` (see [k8s-doc](https://kubernetes.io/docs/concepts/services-networking/service/#loadbalancer)). 
* The `EXTERNAL-IP` is actually `svc.status.loadBalancer.ingress.hostname` on aws.
* Those values are also [classic](https://aws.amazon.com/elasticloadbalancing/) elb(s) which can be found on ec2 console (Navigate to _Load Balancers_).
    Remember to delete them manually after terminating the test cluster.

Observation:

* `istio-statsd-prom-bridge-*` is not there.
* 2 jaeger-agent out of 4 desired
* compare to objects in [istio-doc](https://istio.io/docs/setup/kubernetes/quick-start/#verifying-the-installation)
    * +: es(2), grafana, jaeger(2), kiadi, tracing, zipkin
    * -: ingress, statsd-prom-bridge

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

### bookinfo app
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
###refresh the page, see round-robin of versions of reviews: This has nothing to do with istio
### it is the default behavior of k8s service
###https://istio.io/docs/examples/bookinfo/#confirm-the-app-is-running

### the service is not accessible by curl command
### not sure why??? Google shows some interesting discussion. ^_^
# oc get svc  productpage
NAME          TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
productpage   ClusterIP   172.24.242.211   <none>        9080/TCP   4h
# curl 172.24.242.211:9080/productpage
curl: (56) Recv failure: Connection reset by peer


```

_Notice_ the containers for each service pod: There is an envoy container.
```bash
### https://stackoverflow.com/questions/33924198/how-do-you-cleanly-list-all-the-containers-in-a-kubernetes-pod
### -o jsonpath=
# oc get pod productpage-v1-69b749ff4c-sw596 -o jsonpath={.spec.containers[*].name}
productpage istio-proxy
### OR,
### -o json with jq
# oc get pod productpage-v1-69b749ff4c-sw596 -o json | jq -r '.spec.containers[].name'
productpage
istio-proxy

```

Those container is [injected automatically](https://istio.io/docs/setup/kubernetes/sidecar-injection/#policy) by pod `istio-sidecar-injector-*` with `sidecar.istio.io/inject: "true"` in the definition of deployment.

Also _notice_ that the above url is from route `istio-ingressgateway` in project `istio-system`:
* This is the way of visiting the service, not from the route in app namespace anymore.
* Another is via [the svc definition](https://istio.io/docs/tasks/traffic-management/ingress/#determining-the-ingress-ip-and-ports):

```bash
# echo  http://$(oc get svc -n istio-system istio-ingressgateway -o jsonpath={.status.loadBalancer.ingress[*].hostname})/productpage
http://ae67d308ef4bc11e898f102fa9e2e24a-539964417.us-west-2.elb.amazonaws.com/productpage

```
* The ingress is configured by `bookinfo-gateway.yaml` above, `.spect.selector` of [gateway](https://istio.io/docs/concepts/traffic-management/#gateways).
* The `VirtualService` defined the routing rules for the gateway which it binds to. See [VirtualService](https://istio.io/docs/concepts/traffic-management/#virtual-services).
    * `spec.http[].route[].destination` is the service name in the namespace. Eg, `productpage` will be interpreted as `productpage.myproject.svc.cluster.local`.

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

_Notice_ that the [subnet is defined by pods' labels](https://istio.io/docs/concepts/traffic-management/#rule-configuration) (`app` and `version`):

```bash
# oc get pod --show-labels 
NAME                              READY     STATUS    RESTARTS   AGE       LABELS
details-v1-54b6b58d9c-6wv9p       2/2       Running   0          3h        app=details,pod-template-hash=1062614857,version=v1
productpage-v1-69b749ff4c-sw596   2/2       Running   0          3h        app=productpage,pod-template-hash=2563059907,version=v1
ratings-v1-7ffc85d9bf-qfx4f       2/2       Running   0          3h        app=ratings,pod-template-hash=3997418569,version=v1
reviews-v1-fcd7cc7b6-85k8l        2/2       Running   0          3h        app=reviews,pod-template-hash=978377362,version=v1
reviews-v2-655cc678db-7rg79       2/2       Running   0          3h        app=reviews,pod-template-hash=2117723486,version=v2
reviews-v3-645d59bdfd-8mmt8       2/2       Running   0          3h        app=reviews,pod-template-hash=2018156898,version=v3

```

The above `destination-rule-all-mtls.yaml` file does not change the default routing behavior of the app.
[intelligent-routing](https://istio.io/docs/examples/intelligent-routing/) shows an example of controlling
traffic routing. 


### istio-cli: istioctl
[Install](https://istio.io/docs/setup/kubernetes/download-release/) `istioctl`

```bash
# curl -LO https://github.com/istio/istio/releases/download/1.0.4/istio-1.0.4-linux.tar.gz
# tar xvzf ./istio-1.0.4-linux.tar.gz

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

### [jaeger](https://www.jaegertracing.io/)

```bash
# 
# export JAEGER_URL=$(oc get route -n istio-system jaeger-query -o jsonpath='{.spec.host}')
# echo "https://${JAEGER_URL}"
https://jaeger-query-istio-system.apps.52.32.1.134.xip.io

```

Observation: 

* no service called `productpage` in the list on the UI.

### prometheus

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

### [kiali](https://www.kiali.io/)

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

### grafana

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

### [Red Hat OpenShift Application Runtime Missions](https://docs.openshift.com/container-platform/3.11/servicemesh-install/servicemesh-install.html#rhoar-missions) 
This section is not detailed enough to do test. Leave it as a TODO.


Created [1654462](https://bugzilla.redhat.com/show_bug.cgi?id=1654462) for tracking the above issues/observations.

### [REMOVING THE BOOKINFO APPLICATION](https://docs.openshift.com/container-platform/3.11/servicemesh-install/servicemesh-install.html#removing-bookinfo-application)

See [1651548](https://bugzilla.redhat.com/show_bug.cgi?id=1651548)

```sh
# curl -o cleanup.sh https://raw.githubusercontent.com/Maistra/bookinfo/master/cleanup.sh && chmod +x ./cleanup.sh
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  1596  100  1596    0     0   5858      0 --:--:-- --:--:-- --:--:--  5846
root@ip-172-31-55-123: ~ # ./cleanup.sh
namespace ? [default] myproject
using NAMESPACE=myproject
Deleted config: destinationrules details
Deleted config: destinationrules productpage
Deleted config: destinationrules ratings
Deleted config: destinationrules reviews
Deleted config: virtualservices bookinfo
Deleted config: gateways bookinfo-gateway
Application cleanup may take up to one minute
error: the path "/root/bookinfo.yaml" does not exist
root@ip-172-31-55-123: ~ # echo $?
1
```

[Uninstall istio](https://maistra.io/docs/install/#_upgrading_from_a_pre_existing_installation):
Need to clean up `mutatingwebhookconfigurations`. Otherwise, reinstall won't work.

```bash
# oc get rs
NAME                        DESIRED   CURRENT   READY     AGE
istio-operator-85dc6fbbb9   1         0         0         7m
...
  Warning  FailedCreate  1m (x17 over 7m)  replicaset-controller  Error creating: Internal error occurred: failed calling admission webhook "sidecar-injector.istio.io": Post https://istio-sidecar-injector.istio-system.svc:443/inject?timeout=30s: service "istio-sidecar-injector" not found
```

## istio components

### Envoy

* [Istio uses an extended version of the Envoy proxy. Envoy is deployed as a sidecar to the relevant service in the same Kubernetes pod.](https://istio.io/docs/concepts/what-is-istio/#envoy)
 
* [The graph](https://istio.io/docs/concepts/traffic-management/#pilot-and-envoy) also shows that envoy is in the pod of the service app.

### Pilot

The core component used for traffic management in Istio

### Mixer

### citadal


## [rule configuration](https://istio.io/docs/concepts/traffic-management/#rule-configuration)

_There are four traffic management configuration resources in Istio: VirtualService, DestinationRule, ServiceEntry, and Gateway._

## [security](https://istio.io/docs/concepts/security/#high-level-architecture)

Security in Istio involves multiple components:

* Citadel for key and certificate management
* Sidecar and perimeter proxies to implement secure communication between clients and servers
* Pilot to distribute authentication policies and secure naming information to the proxies
* Mixer to manage authorization and auditing

TODO: more doc reading


## Test with my hello-world app

* [platform-setup/openshift](https://istio.io/docs/setup/kubernetes/platform-setup/openshift/)
* [kubernetes/spec-requirements](https://istio.io/docs/setup/kubernetes/spec-requirements/)
* [sidecar-injection](https://istio.io/docs/setup/kubernetes/sidecar-injection/#policy)

```bash
# oc new-project ttt
# oc adm policy add-scc-to-user anyuid -z default -n ttt
# oc adm policy add-scc-to-user privileged -z default -n ttt




```