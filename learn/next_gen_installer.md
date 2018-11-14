# Next-Gen Installer for OCP 4.0

[repo](https://github.com/openshift/installer)

## Doc

* [gdoc@oc-dev](https://docs.google.com/document/d/1j7bhLXT_cIAjpMh_x2jeegtpE7495Mj5A-EcQsgZEDo/edit)
* [libvirt.on.gce@mike](https://github.com/mffiedler/ocp-svt/blob/master/svt-notes/OCP4/openshift4-libvirt-ocp.md)
* ravi: [playbook](https://github.com/chaitanyaenr/ocp-automation/pull/2), [gdoc](https://docs.google.com/document/d/1NilGxOee6DU6_Yim7TgQx6nN51qc2CvFNDqxgv-1NQ4/edit)

## Steps

### AWS

* Get output of `gpg2 --export --armor hongkliu@redhat.com`. See [how2](tools/gpg.md) 

* Fill the form in the above gdoc to get an IAM account on aws.

Then the application got replied, all the credentials for the IAM user are encrypted as a file
in the attachment. Decrypt by:

```bash
$ gpg2 -d ./hongkliu\@redhat.com.openshift-dev.credentials.txt.gpg
```

The password policy is rather strict and we need to (the first time you login) change it with the pattern like the one
sent to you by admin.

Create a jump node (fedora29):

```bash
$ aws ec2 run-instances --image-id  ami-07e40fe5cf09f0d68 \
     --security-group-ids sg-5c5ace38 --count 1 --instance-type m5.2xlarge --key-name id_rsa_perf \
     --subnet subnet-4879292d --block-device-mappings "[{\"DeviceName\":\"/dev/sda1\", \"Ebs\":{\"VolumeSize\": 30, \"VolumeType\": \"gp2\"}}]" \
     --query 'Instances[*].InstanceId' \
     --tag-specifications="[{\"ResourceType\":\"instance\",\"Tags\":[{\"Key\":\"Name\",\"Value\":\"qe-hongkliu-fedora29-test\"}]}]"

```

Run playbook to set up a jump node:

```bash
$ ansible-playbook -i "<jump_node_public_dns>," playbooks/install_fedora_ocp4.yaml -e "aws_access_key_id=aaa aws_secret_access_key=bbb"

```

Launch a cluster:

```bash
$ cd go/src/github.com/openshift/installer/
### download terraform into bin folder
$ ./hack/get-terraform.sh
### build openshift-install binary in bin folder
./hack/build.sh
### launch a cluster:
### the kerberos_id in the openshift_env.sh file
### will be used in the name of the created instances
### change it to your own id before launching a cluster
$ source /tmp/openshift_env.sh
$ bin/openshift-install create cluster --log-level=debug

```

This will give us a 3-master/3-worker cluster with a bootstrap node which got terminated when
the launching procedure is complete. You can use your kerberos_id to filter out
the instances on ec2 console. _NOTE_: there are other resources too created by the installer.
 

```bash
$ export KUBECONFIG=${PWD}/auth/kubeconfig
$ kubectl cluster-info
Kubernetes master is running at https://hongkliu-api.devcluster.openshift.com:6443

$ oc get node
NAME                           STATUS    ROLES     AGE       VERSION
ip-10-0-130-33.ec2.internal    Ready     worker    30m       v1.11.0+d4cacc0
ip-10-0-151-141.ec2.internal   Ready     worker    30m       v1.11.0+d4cacc0
ip-10-0-167-107.ec2.internal   Ready     worker    29m       v1.11.0+d4cacc0
ip-10-0-27-83.ec2.internal     Ready     master    34m       v1.11.0+d4cacc0
ip-10-0-34-184.ec2.internal    Ready     master    34m       v1.11.0+d4cacc0
ip-10-0-9-10.ec2.internal      Ready     master    34m       v1.11.0+d4cacc0

### ssh to node
$ oc describe node ip-10-0-27-83.ec2.internal | grep ExternalDNS
  ExternalDNS:  ec2-54-197-216-70.compute-1.amazonaws.com

$ ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ~/.ssh/libra.pem  core@ec2-54-197-216-70.compute-1.amazonaws.com
$ sudo -i
# 

```

Destroy a cluster:

```bash
$ source /tmp/openshift_env.sh 
$ bin/openshift-install destroy cluster --log-level=debug


```

TODO:

* controll the cluster: instanceType, number of instances for roles.
* what to do when create/destroy does not work.

### libvert

#### libvert on AWS
https://www.reddit.com/r/aws/comments/993zbz/nested_virtualization_within_ec2_need_advice/


### libvert on GCE

Get an GCE instance:

1. Use `redhat` (google-account) to register for a 10 node Tectonic license at [https://account.coreos.com/](https://account.coreos.com/)
2. Download the pull secret and save it as `openshift-pull-secret.json`
3. install gcloud-cli and configure it. See [how2](../cloud/gce/gce.md#google-cloud-cli)

```bash
$ INSTANCE_NAME=hongkliu-ocp40-ttt
$ gcloud compute instances create "${INSTANCE_NAME}" \
    --image-family openshift4-libvirt \
    --zone us-east1-c \
    --min-cpu-platform "Intel Haswell" \
    --machine-type n1-standard-8 \
    --boot-disk-type pd-ssd --boot-disk-size 256GB \
    --metadata-from-file openshift-pull-secret=openshift-pull-secret.json
    

$ gcloud compute --project "openshift-gce-devel" ssh --zone "us-east1-c" "${INSTANCE_NAME}"
### the first time to run the above command, it will generate the key files and save them in ~/.ssh folder
### afterwards, it will use the generated key files to do the ssh

$ ll ~/.ssh/g*
-rw-------. 1 hongkliu hongkliu 1675 Nov  6 16:42 /home/hongkliu/.ssh/google_compute_engine
-rw-r--r--. 1 hongkliu hongkliu  410 Nov  6 16:42 /home/hongkliu/.ssh/google_compute_engine.pub
-rw-r--r--. 1 hongkliu hongkliu  189 Nov  6 16:43 /home/hongkliu/.ssh/google_compute_known_hosts


### we can also use the external IP (got it from the host) and the pub key to ssh the instance
$ ssh -i ~/.ssh/google_compute_engine.pub hongkliu@35.231.72.97


```

Create OCP 4.0 cluster

```bash
$ create-cluster nested
### be patient

$ oc get pod --all-namespaces

```

Lots of puzzles there:
* what is so special of `openshift4-libvirt` images?
* which part enables nested virtualization?
* [packer](https://www.packer.io/) seems a cool tool. Want to learn it.
