# ostree

* [ostree.readthedocs](https://ostree.readthedocs.io/en/latest/manual/introduction/)



## [RPM-OSTREE](http://www.projectatomic.io/docs/os-updates/)

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