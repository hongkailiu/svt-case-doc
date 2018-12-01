# sysdig

## Doc

* [wiki](https://github.com/draios/sysdig/wiki)
* [getting started](https://github.com/draios/sysdig/wiki/Getting-Started)

## [Install](https://github.com/draios/sysdig/wiki/How-to-Install-Sysdig-for-Linux)

```bash
###Tested with ocp-3.11.22-1-SVT-rhel-m5-gold (ami-07a4cf7e0d75f602e)
$ curl -s https://s3.amazonaws.com/download.draios.com/stable/install-sysdig | sudo bash
```

## sysdig

[Sysdig Overview](https://github.com/draios/sysdig/wiki/Sysdig-Overview),
[Examplese](https://github.com/draios/sysdig/wiki/Sysdig-Examples),
[Quick-Reference](https://github.com/draios/sysdig/wiki/Sysdig-Quick-Reference-Guide#basic-command-list),
[User-Guide](https://github.com/draios/sysdig/wiki/Sysdig-User-Guide)

```bash
# sysdig -n 1
4 17:40:40.969687891 1 <NA> (0) > switch next=29561(prometheus) pgft_maj=0 pgft_min=0 vm_size=0 vm_rss=0 vm_swap=0 

```

`sysdig` list events and read/write the events from/to a file and filters can be applied.

It is always a puzzle to me where a tool like `sysdig` gets those information. All I know is
from `linux kernel` but _where exactly?_

## [chisel](https://github.com/draios/sysdig/wiki/Chisels-Overview)
chisels are (lua) scripts that analyze the sysdig event stream to perform useful actions. 


```bash
### list chisels
# sysdig -cl
## show chisel description
# sysdig -i iobytes_net

``` 

## [csysdig](https://github.com/draios/sysdig/wiki/Csysdig-Overview)

[man page](https://github.com/draios/sysdig/blob/dev/userspace/sysdig/man/csysdig.md)

It looks like `htop`.

```bash
# csysdig
# navigate views via hot-keys

```

Before entering a view, it shows the definitions of columns and action hot keys. 

Seems that k8s views are not working: no data are collected!

Solution:

```bash
# csysdig -k https://ec2-34-214-135-192.us-west-2.compute.amazonaws.com:8443
K8s API error; Status: Failure, Message: nodes is forbidden: User "system:anonymous" cannot list nodes at the cluster scope: no RBAC policy matched, Reason: Forbidden, Details: , Code: nodes is forbidden: User "system:anonymous" cannot list nodes at the cluster scope: no RBAC policy matched

```

Tried also with `# csysdig -k https://redhat:redhat@ec2-34-214-135-192.us-west-2.compute.amazonaws.com:8443`
and got the same error. So the username/password is not used by `csysdig`.


[Workaround](https://github.com/kubernetes-incubator/apiserver-builder/issues/225) (note that it will _uplift all anonymous requests to super-admin level access_):

```bash
# kubectl create clusterrolebinding cluster-system-anonymous --clusterrole=cluster-admin --user=system:anonymous
###revoke the access
# kubectl delete clusterrolebinding cluster-system-anonymous 
```

More secure solution (Many thanks to Mike):

```bash
# csysdig -k https://ec2-34-214-135-192.us-west-2.compute.amazonaws.com:8443 -K /etc/origin/master/admin.crt:/etc/origin/master/admin.key

```

## [tracer](https://github.com/draios/sysdig/wiki/Tracers)
TODO

## [sysdig helm chart](https://github.com/helm/charts/tree/master/stable/sysdig)
TODO

## software on top of sysdig

See [sysdig.com](https://sysdig.com/).

* [sysdigcloud-kubernetes](https://github.com/draios/sysdigcloud-kubernetes)
* [sysdig monitor](https://sysdig.com/products/monitor/)
* [sysdig.com/platform](https://sysdig.com/platform/), [sysdig.com/opensource](https://sysdig.com/opensource/)

## others

* [useful commands related to containers](https://github.com/draios/sysdig/wiki/Sysdig-Examples#containers)
