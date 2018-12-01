# [packer](https://github.com/hashicorp/packer)

[Installation](https://www.packer.io/intro/getting-started/install.html#precompiled-binaries)

```bash
$ curl -LO https://releases.hashicorp.com/packer/1.3.2/packer_1.3.2_linux_amd64.zip
$ unzip packer_1.3.2_linux_amd64.zip
$ cd ~/bin
###https://www.packer.io/intro/getting-started/install.html#troubleshooting
###https://github.com/cracklib/cracklib/issues/7
$ ln -s ../packer_1.3.2/packer packer.io
$ packer.io --version
1.3.2

```

[Template](https://www.packer.io/docs/templates/index.html)

```bash
### Files: https://github.com/hongkailiu/svt-case-doc/tree/master/files/packer/hello
### validate
$ packer.io validate -var-file=variables.json hello-packer.json
### build
$ packer.io build -var-file=variables.json hello-packer.json
...
==> Builds finished. The artifacts of successful builds are:
--> amazon-ebs: AMIs were created:
us-west-2: ami-0499f362a0a2049b2

```

* [builder: amazon-ebs](https://www.packer.io/docs/builders/amazon-ebs.html): Basically it does task `launch temporary instance` in 
the [image provisoner playbook](https://github.com/openshift/svt/blob/master/image_provisioner/playbooks/build_ami.yaml#L11).

* [provisioner: ansible](https://www.packer.io/docs/provisioners/ansible.html): Run the specified playbook for setting up the AMI.

Verification

```bash
$ aws ec2 run-instances --image-id ami-0499f362a0a2049b2 \
    --security-group-ids sg-5c5ace38 --count 1 --instance-type m4.large --key-name id_rsa_perf \
    --subnet subnet-4879292d \
    --query 'Instances[*].InstanceId' \
    --tag-specifications="[{\"ResourceType\":\"instance\",\"Tags\":[{\"Key\":\"Name\",\"Value\":\"qe-hongkliu-packer-test\"}]}]"

### one task in the ansible playbook is `touch file /etc/foo.conf` 
$ rhel.sh ec2-34-209-84-227.us-west-2.compute.amazonaws.com
[ec2-user@ip-172-31-32-71 ~]$ ll /etc/f
filesystems  firewalld/   foo.conf     fstab        
[ec2-user@ip-172-31-32-71 ~]$ ll /etc/foo.conf 
-rw-r--r--. 1 root root 0 Nov  7 19:40 /etc/foo.conf


```

Observation

* An ec2 instance named `Packer Builder` will be created/terminated during the process.
* keyword `rhel` in the AMI name indicates the platform `Red Hat`. 

Clean up
 * delete the created AMI
 * delete the snapshot for the AMI
