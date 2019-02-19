# Next-Gen Installer for OCP 4.0

* [repo](https://github.com/openshift/installer)

## Doc

* [gdoc@oc-dev](https://docs.google.com/document/d/1j7bhLXT_cIAjpMh_x2jeegtpE7495Mj5A-EcQsgZEDo/edit)
* [libvirt.on.gce@mike](https://github.com/mffiedler/ocp-svt/blob/master/svt-notes/OCP4/openshift4-libvirt-ocp.md)
* ravi: [playbook](https://github.com/chaitanyaenr/ocp-automation/pull/2), [gdoc](https://docs.google.com/document/d/1NilGxOee6DU6_Yim7TgQx6nN51qc2CvFNDqxgv-1NQ4/edit)

## Steps

### AWS

* Get output of `gpg2 --export --armor hongkliu@redhat.com`. See [how2](tools/gpg.md) 

* Fill the form in the above gdoc to get an IAM account on aws.

Then the application got replied (James Russell's email), all the credentials for the IAM user are encrypted as a file
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
### removed script: https://github.com/openshift/installer/commit/aff2e983f9438717dec2d182799ba7250035912d
### download terraform into bin folder
(obsoleted 20181211) $ ./hack/get-terraform.sh
### build openshift-install binary in bin folder
$ ./hack/build.sh
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

### ssh to master node
$ oc describe node ip-10-0-27-83.ec2.internal | grep ExternalDNS
  ExternalDNS:  ec2-54-197-216-70.compute-1.amazonaws.com

$ ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ~/.ssh/libra.pem  core@ec2-54-197-216-70.compute-1.amazonaws.com
$ sudo -i
# 

### ssh to worker nodes
### Since there is no public dns associated with worker nodes,
### we have to ssh to worker nodes from a master node as jump node.
### Also need to have the private key file (mode 0600) on the jump node 

```

Destroy a cluster:

```bash
$ source /tmp/openshift_env.sh 
$ bin/openshift-install destroy cluster --log-level=debug


```

Number of instance in a role:

```bash
$ ./bin/openshift-install create install-config
$ vi install-config.yml

```

Instance type: Not working yet. Track with [installer/671](https://github.com/openshift/installer/issues/671).

```bash
$ bin/openshift-install create manifests
$ vi tectonic/99_openshift-cluster-api_master-machines.yaml
$ vi tectonic/99_openshift-cluster-api_worker-machineset.yaml 


```

See the used AMI:

```bash
$ aws ec2 describe-images --owner 531415883065 --output text

```

TODO:

* device mapping of the instances
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


## SVT cases:

For python version of cluster loader and concurrent build scripts, we can 

* copy the kube config to the right path:

    ```
    $ cp ${PWD}/auth/kubeconfig ~/.kube/config
    ```

* [set up python virtualenv](../tools/python.md).

## 4.0 hacking day: 20181206
Email:
* Christopher Alfonso: OCP 4.0 Installer - Jump on in!
* Eric Paris: Thursday kinda hack day, Friday hack day. For every single engineer.

http://try.openshift.com/

Please everyone, do not all try to use us-east-1, spread out across all
4 us regions. PLEASE also bring your cluster down when you are
finished. (Hint: the installer can do that too)

No matter what you try you need to fill in your information on [this spreadsheet](https://docs.google.com/spreadsheets/d/1X0DIEN_uxTzKAtVkEOe9lffq81DCgz2LJ2shMQl4i80).


My steps:

Open http://try.openshift.com/ with chrome (logged in with id obtained from https://developers.redhat.com/).

```bash
### Create fedora29 as above and ssh to it after running the above playbook
### but use the released binary instead of building it from src
$ fdr.sh ec2-34-217-108-124.us-west-2.compute.amazonaws.com
### the content is copied from http://try.openshift.com/
$ vi ~/.secrets/openshift_pull_secret.json

$ mkdir bin
$ cd bin/
$ curl -LO https://github.com/openshift/installer/releases/download/v0.5.0/openshift-install-linux-amd64
$ mv openshift-install-linux-amd64 openshift-install
$ chmod +x ./openshift-install

$ cd
$ curl -LO https://releases.hashicorp.com/terraform/0.11.10/terraform_0.11.10_linux_amd64.zip
$ sudo dnf install unzip -y
$ unzip terraform_0.11.10_linux_amd64.zip 

$ mv terraform bin/

$ openshift-install version
openshift-install v0.5.0
Terraform v0.11.10


```

Open `https://openshift-dev.signin.aws.amazon.com/console` with Firefox. Login with aws-account
obtained above. Switch the region to `us-west-1`.

```bash
###Choose us-west-1 (N. Cal)
$ vi ~/.aws/config
$ vi /tmp/openshift_env.sh

$ source /tmp/openshift_env.sh
$ mkdir aaa
$ cd aaa
$ openshift-install create cluster --log-level=debug

### checking things with oc

$ source /tmp/openshift_env.sh 
$ openshift-install destroy cluster --log-level=debug
```

## 4.0 hacking day: 20181207
* No running of the playbook `install_fedora_ocp4.yaml`.
* Interactive way of installer.

My steps:

Open http://try.openshift.com/ with chrome (logged in with id obtained from https://developers.redhat.com/).

```bash
$ fdr.sh ec2-34-217-108-124.us-west-2.compute.amazonaws.com

$ mkdir bin
$ cd bin/
$ curl -LO https://github.com/openshift/installer/releases/download/v0.5.0/openshift-install-linux-amd64
$ mv openshift-install-linux-amd64 openshift-install
$ chmod +x ./openshift-install

$ cd
$ curl -LO https://releases.hashicorp.com/terraform/0.11.10/terraform_0.11.10_linux_amd64.zip
$ sudo dnf install unzip -y
$ unzip terraform_0.11.10_linux_amd64.zip 
$ rm terraform_0.11.10_linux_amd64.zip

$ mv terraform bin/

$ openshift-install version
openshift-install v0.5.0
Terraform v0.11.10


```

Open `https://openshift-dev.signin.aws.amazon.com/console` with Firefox. Login with aws-account
obtained above. Switch the region to `us-west-2` (Oregon).

```bash
###Choose us-west-2
### set up aws account as indicated by the James Russell's email ~/.aws/{config|credentials}
### use `us-west-2`
$ vi ~/.aws/config


$ mkdir aaa
$ cd aaa

$ openshift-install create cluster 
? Email Address <secret>@redhat.com
? Password [? for help] ******
? SSH Public Key /home/fedora/.ssh/libra.pub
? Base Domain devcluster.openshift.com
? Cluster Name hongkliu
? Pull Secret {"auths":{"cloud.openshift.com":{"auth":"bla=","email":"<secret>@redhat.com"},"quay.io":{"auth":"=","email":"<secret>@redhat.com"}}}
? Platform aws
? Region us-west-2
INFO Using Terraform to create cluster...         

### checking things with oc

$ openshift-install destroy cluster

```

Notice

* `SSH Public Key /home/fedora/.ssh/libra.pub` does not show when you do not have a public key in the `~/.ssh/` folder.
```bash
$ ll ~/.ssh/libra.p*
-rw-------. 1 fedora fedora 1675 Dec  7 16:27 /home/fedora/.ssh/libra.pem
-rw-rw-r--. 1 fedora fedora  381 Dec  7 16:27 /home/fedora/.ssh/libra.pub

```

* `~/.aws/{config|credentials}` use `default` section for creating the cluster:
 
 
 ```bash
$ cat ~/.aws/config 
[default]
region = us-west-2
[fedora@ip-172-31-46-165 ~]$ cat ~/.aws/credentials 
[default]
aws_access_key_id = aaa
aws_secret_access_key = bbb


```

If you change default to eg, `openshift-dev` as indicated in the James Russell's email. It won't
work unless you set up by `export AWS_PROFILE="openshift-dev"`.

* More info
    * (Not tried myself) Walid found it might be helpful if we delete (or move it to other folder for backup reason)
`~/.terraform.d/`.

    * (did not find the password) https://github.com/openshift/installer/issues/411#issuecomment-444620427


## installer 0.6.0: 20181213

* default aws profile; no need for terraform installation.
* console pod is running but URL `https://console-openshift-console.apps.hongkliu.devcluster.openshift.com/` is not working
    * tried in the afternoon, the url is working. The username and password is at the end of the output of installer.
    * it is an `okd` deployment from the login page and the link to the doc page.
    * seems logout does not work. ^_^

## installer 0.8.0: 20190102

Hit the error below. Ignoring it seems OK.

```bash
$ openshift-install create cluster
? SSH Public Key /home/fedora/.ssh/libra.pub
? Platform aws
? Region us-west-2
ERROR list hosted zones: Throttling: Rate exceeded
        status code: 400, request id: 21f65da3-0ec9-11e9-b6a3-39da04a3cd7d 
? Base Domain devcluster.openshift.com

```

## installer 0.9.1: 20190109

Using aws account from Aleks:

```
$ openshift-install version
openshift-install v0.9.1

$ openshift-install create cluster
? SSH Public Key /home/fedora/.ssh/libra.pub
? Platform aws
? Region us-east-2
? Base Domain qe.devcluster.openshift.com
? Cluster Name hongkliu
? Pull Secret [? for help] *************************************************************************************************
INFO Creating cluster...            

```

Note that the base domain `qe.devcluster.openshift.com` is auto-filled by the installer.

Tested with Vikas' instructions: _This will install OCP images instead of OKD images._
[art-notes](https://mojo.redhat.com/groups/atomicopenshift/blog/2019/01/11/ocp-40-high-touch-beta-htb-notes-from-art)

```
###1. Please have your pull secret from try.openshift,com ready before you do this.
###2. Login (with your github id) to https://api.ci.openshift.org/console/catalog and note your userid and login token
###3. oc login https://api.ci.openshift.org --token <api.ci login token>
###Step 4:
$ docker login -u $(oc whoami) -p $(oc whoami -t) registry.svc.ci.openshift.org

###Step 5:
$ export _OPENSHIFT_INSTALL_RELEASE_IMAGE_OVERRIDE=registry.svc.ci.openshift.org/ocp/release:4.0.0-0.nightly-2019-01-08-152529
$ export OPENSHIFT_INSTALL_RELEASE_IMAGE_OVERRIDE=registry.svc.ci.openshift.org/ocp/release:4.0.0-0.nightly-2019-01-08-152529

###Step 6: Thanks to Jianlin
$ cat ~/.docker/config.json 
{
	"auths": {
		"registry.svc.ci.openshift.org": {
			"auth": "<secret>"
		}
	}
}

###Add an auth for "registry.svc.ci.openshift.org" into the pull secret.

```
### without step 6: 20190109

```
$ openshift-install create cluster
? SSH Public Key /home/fedora/.ssh/libra.pub
? Platform aws
? Region us-west-2
ERROR list hosted zones: Throttling: Rate exceeded
        status code: 400, request id: e0035898-1452-11e9-baee-cf7f448afe36 
? Base Domain devcluster.openshift.com
? Cluster Name hongkliu
? Pull Secret [? for help] *************************************************************************************************WARNING Found override for ReleaseImage. Please be warned, this is not advised 
INFO Creating cluster...                          
INFO Waiting up to 30m0s for the Kubernetes API... 
FATAL waiting for Kubernetes API: context deadline exceeded 

```

```
$ openshift-install create cluster --dir=./20190110.vikas
? SSH Public Key /home/fedora/.ssh/libra.pub
? Platform aws
? Region us-west-2
ERROR list hosted zones: Throttling: Rate exceeded
        status code: 400, request id: 19a9f38a-14e7-11e9-889f-b9e1f6d95d40 
? Base Domain devcluster.openshift.com
? Cluster Name hongkliu
? Pull Secret [? for help] *************************************************************************************************WARNING Found override for ReleaseImage. Please be warned, this is not advised 
INFO Creating cluster...                          
INFO Waiting up to 30m0s for the Kubernetes API... 
INFO API v1.11.0+406fc897d8 up                    
INFO Waiting up to 30m0s for the bootstrap-complete event... 
INFO Destroying the bootstrap resources...        
INFO Waiting up to 10m0s for the openshift-console route to be created... 
INFO Install complete!                            
INFO Run 'export KUBECONFIG=/home/fedora/20190110.vikas/auth/kubeconfig' to manage the cluster with 'oc', the OpenShift CLI. 
INFO The cluster is ready when 'oc login -u kubeadmin -p <secret>' succeeds (wait a few minutes). 
INFO Access the OpenShift web-console here: https://console-openshift-console.apps.hongkliu.devcluster.openshift.com 
INFO Login to the console with user: kubeadmin, password: <secret>

```

Checking:

```
$ oc get clusterversion version -o json | jq .status.current
{
  "payload": "registry.svc.ci.openshift.org/ocp/release@sha256:f820eaad16c66f08fe53acfccd9c27a665c36cf714aeefba44dc923432ac840e",
  "version": "4.0.0-0.nightly-2019-01-08-152529"
}

### some cool 4.0 commands:
$ oc adm release info --pullspecs
$ oc adm release extract --from=registry.svc.ci.openshift.org/ocp/release:4.0.0-0.nightly-2019-01-10-030048 --to=./abc

```

## extract bin from nightly builds

Steps: [install_output.md](../install_output.md).

### 20190114: 4.0.0-0.nightly-2019-01-12-000105: Good

```
$ oc adm release info --pullspecs registry.svc.ci.openshift.org/ocp/release:4.0.0-0.nightly-2019-01-12-000105 | grep installer
```

### 20190115

4.0.0-0.nightly-2019-01-15-010905 and 4.0.0-0.nightly-2019-01-15-034457: Bad

```
$ ./openshift-install version
./openshift-install v4.0.0-0.139.0.0-dirty

ERROR: logging before flag.Parse: E0115 14:25:49.385659    1111 streamwatcher.go:109] Unable to decode an event from the watch stream: http2: server sent GOAWAY and closed the connection; LastStreamID=1, ErrCode=NO_ERROR, debug=""
WARNING RetryWatcher - getting event failed! Re-creating the watcher. Last RV: 6569 
DEBUG added openshift-master-controllers.157a0bce09346f7c: controller-manager-m24s7 became leader 
ERROR: logging before flag.Parse: E0115 14:26:48.320336    1111 streamwatcher.go:109] Unable to decode an event from the watch stream: http2: server sent GOAWAY and closed the connection; LastStreamID=1, ErrCode=NO_ERROR, debug=""
WARNING RetryWatcher - getting event failed! Re-creating the watcher. Last RV: 9507 
FATAL waiting for bootstrap-complete: timed out waiting for the condition
```

4.0.0-0.nightly-2019-01-15-064327: good

```
$ oc get clusterversion
NAME      VERSION                             AVAILABLE   PROGRESSING   SINCE     STATUS
version   4.0.0-0.nightly-2019-01-15-064327   True        False         1m        Cluster version is 4.0.0-0.nightly-2019-01-15-064327

$ oc get clusterversion version -o json | jq .status.desired
{
  "payload": "registry.svc.ci.openshift.org/ocp/release@sha256:584f8f454184f6ece5679bf8103560f450e557d1d98711a4540d822c255fbeee",
  "version": "4.0.0-0.nightly-2019-01-15-064327"
}

```

The web console does not work: [bz 1666846](https://bugzilla.redhat.com/show_bug.cgi?id=1666846)

### 20190116: 0.10.0: app routes still broken

```
$ ./openshift-install version
./openshift-install v0.10.0

```

Mike and Jeremy: "_OPENSHIFT_INSTALL_RELEASE_IMAGE_OVERRIDE" works and the one without underscore does not.

### 20190122: 4.0.0-0.nightly-2019-01-21-005139 

```
$ ./openshift-install version
./openshift-install v4.0.0-0.143.0.0-dirty

$ ./openshift-install create install-config
###https://gist.github.com/akrzos/a04b25e1adadfdccf9d7785a4e8f6f7b
$ vi ./install-config.yaml 
...
machines:
- name: master
  platform: 
    aws:
      type: m5.xlarge
      rootVolume:
        size: 100
        type: gp2
  replicas: 3
- name: worker
  platform: 
    aws:
      type: m5.xlarge
      rootVolume:
        iops: 2400
        size: 200
        type: io1
  replicas: 3
...

master:
[core@ip-10-0-4-53 ~]$ lsblk 
NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
nvme0n1     259:0    0  100G  0 disk 
├─nvme0n1p1 259:1    0  300M  0 part /boot
└─nvme0n1p2 259:2    0 99.7G  0 part /sysroot

worker:
[core@ip-10-0-143-36 ~]$ lsblk 
NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
nvme0n1     259:0    0   200G  0 disk 
├─nvme0n1p1 259:1    0   300M  0 part /boot
└─nvme0n1p2 259:2    0 199.7G  0 part /sysroot

### we can also check with ec2 console, the instance type, the storage type, io1 or gp2
### and iops value for io1
### they all work as defined in the above install-config.yaml

```

Tried also with `build from src` and `replicas: 2` for both master and worker. Hit problems.

### 20190124: 4.0.0-0.nightly-2019-01-23-075151 

```
$ ./openshift-install version
./openshift-install v4.0.0-0.145.0.0-dirty

$ vi ./install-config.yaml 
...
machines:
- name: master
  platform: 
    aws:
      type: m5.xlarge
      rootVolume:
        size: 100
        type: gp2
  replicas: 3
- name: worker
  platform: 
    aws:
      type: m5.xlarge
      rootVolume:
        size: 100
        type: gp2
  replicas: 4
...

```

### 20190125: 4.0.0-0.nightly-2019-01-25-034943

```
### Using rhel gold ami as jump node
$ aws ec2 run-instances --image-id ami-0a306989ad7802401     --security-group-ids sg-5c5ace38 --count 1 --instance-type m5.xlarge --key-name id_rsa_perf     --subnet subnet-4879292d     --query 'Instances[*].InstanceId'     --tag-specifications="[{\"ResourceType\":\"instance\",\"Tags\":[{\"Key\":\"Name\",\"Value\":\"qe-hongkliu-gold-jn\"}]}]"

```

```
# ./openshift-install version
./openshift-install v4.0.0-0.147.0.0-dirty

```

### 20190130: gluster

1. Add auth for `registry.reg-aws.openshift.com:443` into your pull secret.

```
$ oc login https://api.reg-aws.openshift.com --token=<secret_for_qe_user_ask_your_admin>
$ docker login -u $(oc whoami) -p $(oc whoami -t) registry.reg-aws.openshift.com:443
# cat ~/.docker/config.json
### add an auth entry for `registry.reg-aws.openshift.com:443` into your pull secret for 4.0 installer

### we can verify that the pull secret works with this pod def:
# cat ./pod_test.yaml 
apiVersion: v1
kind: Pod
metadata:
  name: web
  labels:
    app: web
spec:
  containers:
  - name: test-go
    image: registry.reg-aws.openshift.com:443/hongkliu-test/fio:3.11.7-1
    ports:
    - containerPort: 8080

```

2. make 3 workers in the same zone;

```
# oc project openshift-cluster-api
### we choose this zone: `us-east-2c`
### change the replicas to 3, for example
# oc edit machineset hongkliu27-worker-us-east-2c
# oc get machineset hongkliu27-worker-us-east-2c
NAME                           DESIRED   CURRENT   READY     AVAILABLE   AGE
hongkliu26-worker-us-east-2c   3         3         3         3           3h

# oc get machine | grep worker | grep us-east-2c | awk '{print $1}' | while read i; do oc get machine $i -o json | jq -r .status.nodeRef.name; done
ip-10-0-170-140.us-east-2.compute.internal
ip-10-0-163-155.us-east-2.compute.internal
ip-10-0-161-45.us-east-2.compute.internal

# oc get machine | grep worker | grep us-east-2c | awk '{print $1}' | while read i; do oc get machine $i -o json | jq -r .status.providerStatus.instanceId; done
i-070265799391e5c90
i-0e84814d88760fab2
i-09d93148b7356d1dc

# for i in {1..3}; do aws ec2 create-volume --size 1000 --region us-east-2 --availability-zone us-east-2c --volume-type gp2 --tag-specifications="[{\"ResourceType\":\"volume\",\"Tags\":[{\"Key\":\"Name\",\"Value\":\"qe-hongkliu-gluster-${i}\"}]}]" | jq -r .VolumeId; done
vol-0aad2c324d8278563
vol-0b7acac0bcab990ad
vol-0e417a360fa54500c

# aws ec2 attach-volume --volume-id vol-0aad2c324d8278563  --instance-id i-070265799391e5c90 --device /dev/sdf
# aws ec2 attach-volume --volume-id vol-0b7acac0bcab990ad  --instance-id i-0e84814d88760fab2 --device /dev/sdf
# aws ec2 attach-volume --volume-id vol-0e417a360fa54500c  --instance-id i-09d93148b7356d1dc --device /dev/sdf

### check on ec2 console or ssh to the chosen nodes then `lsblk` to check if the device is attached. Eg,

$ ssh core@ip-10-0-169-178.us-east-2.compute.internal
[core@ip-10-0-169-178 ~]$ lsblk 
NAME    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
xvda    202:0    0   32G  0 disk 
├─xvda1 202:1    0  300M  0 part /boot
└─xvda2 202:2    0 31.7G  0 part /sysroot
xvdf    202:80   0 1000G  0 disk 

```

update on 20190214:

```
# oc project openshift-machine-api
# oc edit machinesets.machine.openshift.io hongkliu1-worker-us-east-2c
# oc get machinesets.machine.openshift.io hongkliu1-worker-us-east-2c
NAME                          DESIRED   CURRENT   READY   AVAILABLE   AGE
hongkliu1-worker-us-east-2c   3         3         3       3           163m

# oc get machines.machine.openshift.io | grep worker | grep us-east-2c | awk '{print $1}' | while read i; do oc get machines.machine.openshift.io $i -o json | jq -r .status.nodeRef.name; done
ip-10-0-162-10.us-east-2.compute.internal
ip-10-0-161-240.us-east-2.compute.internal
ip-10-0-172-218.us-east-2.compute.internal

# oc get machines.machine.openshift.io | grep worker | grep us-east-2c | awk '{print $1}' | while read i; do oc get machines.machine.openshift.io $i -o json | jq -r .status.providerStatus.instanceId; done
i-0fc17ec93874ef75f
i-0bf23c0d37a42ad0c
i-0e1bec085eaa54c55

# for i in {1..3}; do aws ec2 create-volume --size 1000 --region us-east-2 --availability-zone us-east-2c --volume-type gp2 --tag-specifications="[{\"ResourceType\":\"volume\",\"Tags\":[{\"Key\":\"Name\",\"Value\":\"qe-hongkliu-gluster-${i}\"}]}]" | jq -r .VolumeId; done
vol-03307f3f4b946f63d
vol-08038932a6c46724f
vol-006c3cae73e078760

# aws ec2 attach-volume --volume-id vol-03307f3f4b946f63d  --instance-id i-0fc17ec93874ef75f --device /dev/sdf
# aws ec2 attach-volume --volume-id vol-08038932a6c46724f  --instance-id i-0bf23c0d37a42ad0c --device /dev/sdf
# aws ec2 attach-volume --volume-id vol-006c3cae73e078760  --instance-id i-0e1bec085eaa54c55 --device /dev/sdf

$ ssh core@ip-10-0-18-219.us-east-2.compute.internal
$ lsblk 
NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
nvme0n1     259:0    0  100G  0 disk 
├─nvme0n1p1 259:1    0  300M  0 part /boot
└─nvme0n1p2 259:2    0 99.7G  0 part /sysroot
nvme1n1     259:3    0 1000G  0 disk 

```

3. get a jump node on in the same VPC. The script [my_install_post.sh](../scripts/my_install_post.sh) can help.

```
# ssh -i /root/.ssh/libra.pem -o UserKnownHostsFile=/dev/null fedora@ec2-13-59-153-69.us-east-2.compute.amazonaws.com
$ sudo dnf install -y ansible-2.6.5-1.fc29
### set up ansible
$ cat ~/.ansible.cfg
[defaults]
host_key_checking = False

$ git clone https://github.com/openshift/openshift-ansible.git
$ git -C ./openshift-ansible checkout devel-40
$ git -C ./openshift-ansible log --oneline -1
84b7199c4 (HEAD -> devel-40, origin/devel-40) Merge pull request #10985 from vrutkovs/devel-40-scaleup-ci

$ curl -LO https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/gfs_inv_4.0.file
### modify `gfs_inv_4.0.file` to use the right nodes

$ touch /home/fedora/install-config-ansible.yml
$ ansible-playbook -i ./gfs_inv_4.0.file ./openshift-ansible/playbooks/openshift-glusterfs/config.yml

### Failed at TASK [Ensure openshift-ansible installer package deps are installed] 
fatal: [ip-10-0-170-140.us-east-2.compute.internal]: FAILED! => {"attempts": 3, "changed": false, "msg": "missing required arguments: image, backend"}

```

### 20190219: 4.0.0-0.ci-2019-02-19-055341

```
compute:
- name: worker
  platform: 
    aws:
      type: m5.4xlarge
      rootVolume:
        size: 100
        type: gp2
  replicas: 6
controlPlane:
  name: master
  platform: 
    aws:
      type: m5.xlarge
      rootVolume:
        size: 100
        type: gp2
  replicas: 3
```

## troubleshooting

* Mike's tips
    * waiting for bootstrap complete too long -> ssh into the bootstrap node and journalctl the kubelet service.
    * Cluster Name <kerberos-id><n>: use `n` to make the cluster name unique for all clusters.
    * There are 4 parts of the AWS console to look for orphaned resources:  EC2, Route53, VPC and IAM roles.

* [troubleshooting.doc@github](https://github.com/openshift/installer/blob/master/docs/user/troubleshooting.md)

* Clean up (thanks to Siva): If you lost your install dir, you want to clean up your installed cluster, you could follow  [solutions/3826921](https://access.redhat.com/solutions/3826921), which is covered in [OCP-22168](https://polarion.engineering.redhat.com/polarion/#/project/OSE/workitem?id=OCP-22168).