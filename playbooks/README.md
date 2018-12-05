# Playbooks

## nfs
The playbook will start an nfs server which is backed up by an oc service.

```sh
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i "${MASTER_HOSTNAME}," --private-key ./id_rsa_perf ./nfs_via_pod.yml
```

## clean docker images on computing nodes
Run on master
```sh
# ../scripts/cat_nodes.sh > /tmp/inv.file
# #change the keyword of docker images in ./clean_docker_images.yml if needed
# ansible-playbook -i /tmp/inv.file  ./clean_docker_images.yml -v
```

## pbench
TODO

## launch device-mapper module

```sh
$ ansible-playbook -i inv.file playbooks/dm_thin_pool.yml
```

## prepare cns-deploy tool

```sh
$ ansible-playbook -i inv.file playbooks/cns_deploy.yml
```

## jenkins for terraform and flexy
Install a Jenkins instance on Fedora and init a job on it which can be used
to install OCP cluster on aws-ec2.

```bash
$ ansible-playbook -i "<fedara_ip_or_hostname>," playbooks/install_fedora_local.yaml

```

After running the playbook, edit those files with the valid keys:

```bash
# ll /data/secret/secret.*
-rw-r--r--. 1 root root 229 Dec  5 14:18 /data/secret/secret.sh
-rw-r--r--. 1 root root  93 Dec  5 14:18 /data/secret/secret.tfvars

```

Then login the Jenkins UI and trigger a job there.
