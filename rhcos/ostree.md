# ostree

* [ostree.readthedocs](https://ostree.readthedocs.io/en/latest/manual/introduction/)

```
### Tested on rhcos (a master node of ocp 4.0)
$ ostree --version
libostree:
 Version: '2018.10'
 Git: ba57eb4bae322df85a0cdcb4a82617cbea84e2f5
 DevelBuild: yes
 Features:
  - libcurl
...

```

Play with `ostree` cli:

```
### hello-world example
### https://ostree.readthedocs.io/en/latest/manual/introduction/#hello-world-example
$ ostree --repo=repo init
$ ll
total 0
drwxr-xr-x. 7 core core 89 Jan 10 20:46 repo

...

```

## [RPM-OSTREE](http://www.projectatomic.io/docs/os-updates/)

* [rpm-ostree.readthedocs](https://rpm-ostree.readthedocs.io/en/latest/)

On Atomic Host, <code>rpm-ostree</code> is integrated into <code>atomic host</code> command.

```sh
[fedora@ip-172-31-25-0 ~]$ rpm-ostree --version
rpm-ostree:
 Version: 2017.8
 Git: c382192257aafac720be38fdd38bfcaa84fd98c2
 Features:
  - compose

# #check configuration
[fedora@ip-172-31-25-0 ~]$ cat /etc/ostree/remotes.d/fedora-atomic.conf 
[remote "fedora-atomic"]
url=https://kojipkgs.fedoraproject.org/atomic/26/
gpg-verify=true
gpgkeypath=/etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-26-primary

# #get status
[fedora@ip-172-31-25-0 ~]$ atomic host status
State: idle
Deployments:
● fedora-atomic:fedora/26/x86_64/atomic-host
                   Version: 26.120 (2017-09-05 00:05:09)
                    Commit: 0b0127864022dd6ffad1a183241fbd5482ef5a1642ff3c8751c2e6cae6070b1a
              GPGSignature: Valid signature by E641850B77DF435378D1D7E2812A6B4B64DAB85D

```

On RHCOS: 20191010

```
$ rpm-ostree --version
rpm-ostree:
 Version: '2018.10'
 Git: 59d8ee70941eb48a7924d7ab8d947401e5df837d
 Features:
  - compose
  - rust

$ rpm-ostree status
State: idle
AutomaticUpdates: disabled
Deployments:
● pivot://registry.svc.ci.openshift.org/rhcos/maipo@sha256:002775f2f4fd57eb2196dbfffa3303a30b4860a6d3ed80a0572dde28f0ad16cf
              CustomOrigin: Provisioned from oscontainer
                   Version: 47.249 (2019-01-07T17:47:35Z)


```

Remember in Xiaoli's email, _Please note: 47.249 should be treated as Beta candidate build and used for beta testing._
We can also obtain this information by:

```
$ cat /etc/*release | grep OSTREE_VERSION
OSTREE_VERSION=47.249

```

Install a pkg: Maybe disabled by RHCOS build.

```
$ sudo -i
# rpm-ostree install git
Checking out tree 39ec670... done
error: No enabled repositories

```

[This page](https://www.reddit.com/r/Fedora/comments/8mtuw6/fedora_atomic_workstation_is_there_a_way_to/) says that _there is no `rpm-ostree search` yet_ and what is the workaround.