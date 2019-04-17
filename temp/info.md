# Some general info

## [rhocs](../rhocs)

Attach additional devices:

* attach when launching an instance: [terraform](https://github.com/hongkailiu/svt-case-doc/blob/master/files/terraform/4_node_cluster/ocp.tf#L80), [flexy-template](http://file.rdu.redhat.com/~hongkliu/flexy.templates/gluster.ocp-3.11.0-0.9.0/template.ose311-aws-svt) can do it similarly. 

* attach after launching an instance: [aws-cli](https://github.com/hongkailiu/svt-case-doc/blob/master/ocp_4.0/next_gen_installer.md#20190130-gluster), and [gcloud-cli](https://github.com/hongkailiu/svt-case-doc/blob/master/cloud/gce/gce.md#disk).

### cns/glusterfs

* OCP version: CNS is not yet supported on OCP 4+. So all cases and bugs related target OCP 3.X.

* Cluster infra: 3 (compute) nodes dedicated to glusterfs pods and 1 (infra) node for heketi pod and block-provisioner pod. Those nodes are `4xlarge` (either `m4` or `m5`). During stress tests, we keep the testing pods away from those nodes.

* Installation
    * An OCP cluster with at least 3 compute nodes. Each of 3 compute nodes: at least one block device for glusterfs.
    * [gfs.inventory.example](https://github.com/hongkailiu/test-go/blob/master/test_files/ocpft/inv/gfs.file): [reference.doc](https://github.com/openshift/openshift-ansible/tree/release-3.11/playbooks/openshift-glusterfs).
    * CNS images: dev push to brew. Sync to [aws-reg](https://console.reg-aws.openshift.com/console/project/rhgs3/browse/images) is never stable. Manual push: [jenkins job](https://openshift-qe-jenkins.rhev-ci-vms.eng.rdu2.redhat.com/job/cns_images_check_in_brew/).

### ceph

Replacing gluster, ceph is the new storage solution for OpenShift.
Containerized ceph is provided by Rook:

* It provides ceph-rbd (raw block device), ceph-fs (shared fs), and object (like aws-s3).
* Provisioner:
    * rhd: part of kubelet.
    * shared fs: via ceph-csi driver (not tested yet, requiring kube1.13).

## svt storage tests

Except fio, all [svt storage tests](https://github.com/openshift/svt/tree/master/storage) are independent of pbench.

* fio: the test create only 1 pod. The script is ready for multi-pods.
* git and jenkins have gone through a run on OCP 4 without pbench. The rest is only tested on OCP 3.

## Anything else?