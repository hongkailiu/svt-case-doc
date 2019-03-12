# Networking

## Doc

* [networking](https://docs.openshift.org/latest/architecture/additional_concepts/networking.html): [ovs](https://www.openvswitch.org/)
* [managing-network](https://docs.openshift.org/latest/admin_guide/managing_networking.html#admin-guide-networking-networkpolicy)
* [routes](https://docs.openshift.org/latest/architecture/core_concepts/routes.html)
* [router](https://docs.openshift.org/latest/install_config/router/index.html)
* [service](https://docs.openshift.org/latest/architecture/core_concepts/pods_and_services.html#services)
* [networking@k8s](https://kubernetes.io/docs/concepts/cluster-administration/networking/)

## Flexy


### Network plugin
When flexy generates the inventory file (2), the following parameter shows which network plugin is installed:

<code>os_sdn_network_plugin_name=redhat/openshift-ovs-subnet</code>

We can change it to the following value if installing 

<code>os_sdn_network_plugin_name="redhat/openshift-ovs-multitenant"</code>

Checking on master config:

```sh
# grep "network" /etc/origin/master/master-config.yaml 
networkConfig:
  networkPluginName: redhat/openshift-ovs-multitenant
```

### Router plugin

Checking running router images:

```sh
# oc get pod router-1-mxsb0 -o yaml | grep image
    image: registry.ops.openshift.com/openshift3/ose-haproxy-router:v3.6.153
```

## [Network interfaces on AWS EC2 instances](https://docs.openshift.org/latest/architecture/additional_concepts/sdn.html)

### master

```sh
# ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN qlen 1
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001 qdisc mq state UP qlen 1000
    link/ether 02:ca:ea:35:d0:e4 brd ff:ff:ff:ff:ff:ff
    inet 172.31.62.245/18 brd 172.31.63.255 scope global dynamic eth0
       valid_lft 2551sec preferred_lft 2551sec
    inet6 fe80::ca:eaff:fe35:d0e4/64 scope link 
       valid_lft forever preferred_lft forever
3: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN 
    link/ether 02:42:59:53:9d:59 brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 scope global docker0
       valid_lft forever preferred_lft forever
4: ovs-system: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether ee:19:bb:77:62:a4 brd ff:ff:ff:ff:ff:ff
5: br0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether 36:be:b4:b5:da:48 brd ff:ff:ff:ff:ff:ff
9: vxlan_sys_4789: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 65470 qdisc noqueue master ovs-system state UNKNOWN qlen 1000
    link/ether ba:02:ac:9a:97:6b brd ff:ff:ff:ff:ff:ff
    inet6 fe80::b802:acff:fe9a:976b/64 scope link 
       valid_lft forever preferred_lft forever
10: tun0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN qlen 1000
    link/ether 96:68:8b:bd:e3:5c brd ff:ff:ff:ff:ff:ff
    inet 172.20.0.1/24 scope global tun0
       valid_lft forever preferred_lft forever
    inet6 fe80::9468:8bff:febd:e35c/64 scope link 
       valid_lft forever preferred_lft forever
```

### other nodes

More network interfaces like the following:

```sh
13: veth58d5e401@if3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 8951 qdisc noqueue master ovs-system state UP 
    link/ether 16:45:f0:1b:b2:c0 brd ff:ff:ff:ff:ff:ff link-netnsid 1
    inet6 fe80::1445:f0ff:fe1b:b2c0/64 scope link 
       valid_lft forever preferred_lft forever
```

## Functional cases (some)

* [tcms 497542](https://tcms.engineering.redhat.com/case/497542/?from_plan=14587)
* [tcms 499866](https://tcms.engineering.redhat.com/case/499866/?from_plan=14587)
* [tcms 508109](https://tcms.engineering.redhat.com/case/508109/?from_plan=14587)

Use [this rc](../files/rc_111.yaml) to create pods. Or [this one](https://raw.githubusercontent.com/openshift-qe/v3-testfiles/master/networking/list_for_pods.json).

```sh
# oc create -f /tmp/rc_111.yaml
```

## Verify network concepts

OCP 3.10:
```sh
# grep "network" /etc/origin/master/master-config.yaml 
networkConfig:
  networkPluginName: redhat/openshift-ovs-networkpolicy

# oc get ds -n  openshift-sdn
NAME      DESIRED   CURRENT   READY     UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
ovs       10        10        10        10           10          <none>          1d
sdn       10        10        10        10           10          <none>          1d

```

## [Service](https://kubernetes.io/docs/concepts/services-networking/service/)

```
### https://kubernetes.io/docs/concepts/services-networking/service/#nodeport
$ oc new-project ttt
$ oc create -f https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/pod_test.yaml
$ oc apply -f - <<EOF
kind: Service
apiVersion: v1
metadata:
  name: web
spec:
  type: NodePort
  selector:
    app: web
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 8080
EOF

$ oc get svc
NAME      TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
web       NodePort   172.30.185.172   <none>        8080:30574/TCP   5s

### on host of node
[core@ip-10-0-132-100 ~]$ curl ip-10-0-132-100.us-east-2.compute.internal:30574
{"version":"0.0.19","ips":["127.0.0.1","::1","10.128.2.14","fe80::94a7:dcff:fec7:c29d"],"now":"2019-03-12T18:41:00.896999948Z"}

```

## [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)



## Service DNS

See [networking@k8s](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#services)
and [networking@oc](https://docs.openshift.com/enterprise/3.0/architecture/additional_concepts/networking.html#openshift-dns)

```bash
my-svc.my-namespace.svc.cluster.local
```

## Reference

* [SRV record](https://en.wikipedia.org/wiki/SRV_record)
* [SkyDNS](https://github.com/skynetservices/skydns)
* [Dnsmasq](http://www.thekelleys.org.uk/dnsmasq/doc.html)
