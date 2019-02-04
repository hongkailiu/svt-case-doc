# [rook](https://rook.io/)

* [rook.io](https://rook.io/), [rook@github](https://github.com/rook/rook)
* [Fabio Bertinatto's mojo](https://mojo.redhat.com/docs/DOC-1189365)

## Installation

```
#  go get -d github.com/rook/rook
# cd /root/go/src/github.com/rook/rook/cluster/examples/kubernetes/ceph/

### set up privilege: https://rook.io/docs/rook/master/openshift.html
# oc create -f scc.yaml

# vi operator.yaml
        - name: ROOK_HOSTPATH_REQUIRES_PRIVILEGED
          value: "true"

# oc create -f operator.yaml
### https://github.com/rook/rook/issues/2612

# oc get pod -n rook-ceph-systemNAME                                 READY   STATUS                 RESTARTS   AGE
rook-ceph-agent-6mvrd                0/1     CreateContainerError   0          31m
rook-ceph-agent-lrl8t                0/1     CreateContainerError   0          31m
rook-ceph-agent-x6b94                0/1     CreateContainerError   0          31m
rook-ceph-operator-765b9f645-t68vz   1/1     Running                0          32m
rook-discover-27fwl                  1/1     Running                0          31m
rook-discover-88nsq                  1/1     Running                0          31m
rook-discover-x9nnc                  1/1     Running                0          31m


# oc create -f cluster.yaml

###
# oc create -f filesystem.yaml

```

Blocked by [issues/2612](https://github.com/rook/rook/issues/2612).