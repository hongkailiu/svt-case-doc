# kubectl

## Install from yum/dnf

See [oc_cli.md](../origin/oc_cli.md#install-from-yumdfn).

Or

```sh
### fedora 27:
$ sudo dnf install kubernetes-client
```

## [Install from binary](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl)

```sh
$ mkdir k8s
$ cd k8s/
$ curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
$ chmod +x ./kubectl
$ cd ~/bin/
$ ln -s ../k8s/kubectl kubectl
$ which kubectl
~/bin/kubectl

```

