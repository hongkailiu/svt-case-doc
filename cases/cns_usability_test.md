# CNS: Usability Test

## heketi/block-provisioner pod can survive of node-draining

Label 2 nodes with `heketi=heketi` and `gfsbp=gfsbp` which is the node selector for
`dc/heketi-storage`.

Then create 300 pods with glusterfs PVCs which usually takes about 30 mins.
During the creation, drain the node where heketi is running.

Expected result: 300 pods in running state.

Extra work on the case: no

### Steps

Install CNS with 1000g and 3 replicas.

Label 2 nodes with `heketi=heketi`:

```sh
oc label node ip-172-31-28-169.us-west-2.compute.internal heketi=heketi gfsbp=gfsbp
oc label node ip-172-31-33-215.us-west-2.compute.internal heketi=heketi gfsbp=gfsbp

# oc patch -n glusterfs deploymentconfigs/glusterblock-storage-provisioner-dc --patch '{"spec": {"template": {"spec": {"nodeSelector": {"gfsbp": "gfsbp"}}}}}'
# oc patch -n glusterfs deploymentconfigs/heketi-storage --patch '{"spec": {"template": {"spec": {"nodeSelector": {"heketi": "heketi"}}}}}'
```

Start to create 200 pods with glusterfs-storage PVCs as described [here](glusterFS_stress.md#run-test)

Before the above finished (about 30 pod are running), do the following in anther terminal:

```sh
# heketi_node=$(oc get pod -n glusterfs -o wide | grep heketi | awk '{print $7}')
# oc label node ${heketi_node} heketi-
# oc rollout latest heketi-storage -n glusterfs
```

Or delete the oc pod directly:

```sh
# oc delete pod -n glusterfs "$(oc get pod -n glusterfs | grep heketi | awk '{print $1}')"
```

There should be 200 pods in Running states.

## No impact on pods when one of glusterfs pods get restarted

10 pods with glusterfs PVCs and the pods write logs onto files on PVCs.

Restart glusterfs pod one after another with a reasonable interval: drain
node or delete pod or remove label `glusterfs=storage-host` on the
glusterfs node which is the node selector for ds/glusterfs-storage.

Expected result: all logs are fine with correct content.

Extra work on the case: Need to implement the logic with Mike's logging
tool or start from scratch.

### Steps

```sh
# cd svt/openshift_scalability
# curl -o ./content/fio/fio-template3.json https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/fio-template3.json
# 1 projects, 30 templates
# vi content/fio/fio-parameters.yaml
...
        file: ./content/fio/fio-template2.json
        parameters:
          - STORAGE_CLASS: "glusterfs-storage" # this is name of storage class to use
          - STORAGE_SIZE: "30Gi" # this is size of PVC mounted inside pod
          - MOUNT_PATH: "/mnt/pvcmount"
          - DOCKER_IMAGE: "docker.io/hongkailiu/ocp-logtest:20180307"
          - INITIAL_FLAGS: "-o /mnt/pvcmount/test.log --line-length 1024 --word-length 7 --rate 30000 --time 0 --fixed-line --num-lines 900000\n"

tuningsets:
  - name: default
    templates:
      stepping:
        stepsize: 5
        pause: 0 ms
      rate_limit:
        delay: 0 ms
...

# python -u cluster-loader.py -v -f content/fio/fio-parameters.yaml -p 1
```