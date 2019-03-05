# Fedora

## Doc

[https://docs.fedoraproject.org/index.html](https://docs.fedoraproject.org/index.html)

## Launch a Fedora 26 instance on AWS

Use command [here](https://github.com/hongkailiu/svt-case-doc/blob/master/cloud/ec2/ec2.md#fedora-26).

## Install docker
fedora26 docker installation: follow illucent (commented on Jul 29) from [issues/35](https://github.com/docker/for-linux/issues/35).

Or, follow Section <code>Install from a package</code> on the [installation page](https://docs.docker.com/engine/installation/linux/docker-ce/fedora/#install-from-a-package).

## Install other tools

```sh
$ sudo dnf install sysstat
### openshift dev. env.
$ sudo dnf install rpm-build createrepo bsdtar krb5-devel
### check on https://github.com/openshift/origin/blob/master/CONTRIBUTING.adoc
$ sudo dnf install golang golang-race make gcc zip mercurial krb5-devel bsdtar bc rsync bind-utils file jq tito createrepo openssl gpgme gpgme-devel libassuan libassuan-devel

```

## Run byo playbook

Found when installing logging stack: Need <code>libselinux-python</code> and <code>keytool</code>.


```sh
### fedora28: python3-libselinux is installed already
[fedora@ip-172-31-33-174 ~]$ sudo dnf install libselinux-python
# #keytool comes with jdk
[fedora@ip-172-31-33-174 ~]$ sudo rpm -Uvh jdk-8u144-linux-x64.rpm 
# #checking keytool
[fedora@ip-172-31-33-174 ~]$ whereis keytool
keytool: /usr/bin/keytool /usr/share/man/man1/keytool.1
```

## Get Fedora AMI of previous releases
[fedoraproject.org](https://alt.fedoraproject.org/cloud/) only lists the images for the latest Fedora release. We can search for previous
release by its [owner id](https://ask.fedoraproject.org/en/question/51307/ec2-hvm-ami-for-fedora/?answer=73237#post-id-73237):
<code>125523088429</code>.

For example, Fedora 25 with current date _20171018_:

```sh
(awsenv) [hongkliu@hongkliu awscli]$ aws ec2 describe-images --owner 125523088429 --output text --region us-west-2 | grep Fedora-Cloud-Base-25 | grep 20171018
IMAGES	x86_64	2017-10-18T07:38:02.000Z	Created from build Fedora-Cloud-Base-25-20171018.0.x86_64	xen	ami-5b2be823	125523088429/Fedora-Cloud-Base-25-20171018.0.x86_64-us-west-2-PV-gp2-0	machine	aki-fc8f11cc	Fedora-Cloud-Base-25-20171018.0.x86_64-us-west-2-PV-gp2-0	125523088429	True	/dev/sda	ebs	available	paravirtual
IMAGES	x86_64	2017-10-18T07:38:05.000Z	Created from build Fedora-Cloud-Base-25-20171018.0.x86_64	xen	ami-7c25e604	125523088429/Fedora-Cloud-Base-25-20171018.0.x86_64-us-west-2-HVM-standard-0	machine		Fedora-Cloud-Base-25-20171018.0.x86_64-us-west-2-HVM-standard-0	125523088429	True	/dev/sda1	ebs	available	hvm
IMAGES	x86_64	2017-10-18T07:38:29.000Z	Created from build Fedora-Cloud-Base-25-20171018.0.x86_64	xen	ami-c525e6bd	125523088429/Fedora-Cloud-Base-25-20171018.0.x86_64-us-west-2-PV-standard-0	machine	aki-fc8f11cc	Fedora-Cloud-Base-25-20171018.0.x86_64-us-west-2-PV-standard-0	125523088429	True	/dev/sda	ebs	available	paravirtual
IMAGES	x86_64	2017-10-18T07:38:18.000Z	Created from build Fedora-Cloud-Base-25-20171018.0.x86_64	xen	ami-fe26e586	125523088429/Fedora-Cloud-Base-25-20171018.0.x86_64-us-west-2-HVM-gp2-0	machine		Fedora-Cloud-Base-25-20171018.0.x86_64-us-west-2-HVM-gp2-0	125523088429	True	/dev/sda1	ebs	available	hvm
```

Choose the one with _HVM-standard-0_ whose ami id is _ami-7c25e604_.


## [oc cli: auto-completion](https://bierkowski.com/openshift-cli-morsels-enable-oc-shell-completion/)

On F29: `origin-3.11.1-1.fc29.src.rpm` installs `/etc/bash_completion.d/oc`. So no manual steps required.

```sh
$ sudo dnf install bash-completion
$ oc completion bash > oc_completion.sh
$ sudo mv oc_completion.sh /usr/share/bash-completion/completions/oc
```

for [centos](https://medium.com/@ismailyenigul/how-to-enable-openshift-oc-bash-auto-completion-958b80e56e17)

```
# yum -y install bash-completion
# oc completion bash > /etc/bash_completion.d/oc
```

If no root access:

```
###https://serverfault.com/questions/506612/standard-place-for-user-defined-bash-completion-d-scripts
$ mkdir ~/.bash_completion.d
$ oc completion bash > ~/.bash_completion.d/oc
$ vi ~/.bash_completion
for bcfile in ~/.bash_completion.d/* ; do
  . $bcfile
done

```

## fedora <-> win7

* Make Windows installation usb on Fedora 27: [WoeUSB](https://github.com/slacka/WoeUSB): Tried with WoeUSB-2.2.2-1.fc27.x86_64 and Win7

```sh
$ sudo dnf install wxGTK3-devel
$ sudo dnf install WoeUSB
```

* Make fedora installation usb on win7: [MediaWriter](https://github.com/MartinBriza/MediaWriter). Tried MediaWriter 4.1.1 and Fedora 27.


## Fedora gnome on ec2 instance (NOT working yet)

https://devopscube.com/setup-gui-for-amazon-ec2-linux/

https://docs.fedoraproject.org/f26/system-administrators-guide/infrastructure-services/TigerVNC.html

https://www.server-world.info/en/note?os=Fedora_27&p=desktop&f=6

Test with Fedora 27:

```sh
# dnf groupinstall -y "Fedora Workstation"
# dnf groupinstall -y tigervnc-server
```

## virtualization

https://docs.fedoraproject.org/en-US/quick-docs/getting-started-with-virtualization/

```
$ dnf groupinfo virtualization
Group: Virtualization
 Description: These packages provide a graphical virtualization environment.
 Mandatory Packages:
   virt-install
 Default Packages:
   libvirt-daemon-config-network
   libvirt-daemon-kvm
   qemu-kvm
   virt-manager
   virt-viewer
 Optional Packages:
   guestfs-browser
   libguestfs-tools
   python3-libguestfs
   virt-top

```

## gnome-tweak-tool

```
### https://www.dedoimedo.com/computers/fedora-29-perfect-after-install.html
$ sudo dnf install gnome-tweak-tool

```

## filezilla (ftp gui)

```
$ sudo dnf install filezilla
```

## tilix (cool terminal application)

```
$ sudo dnf install tilix
```

## foxit (pdf viewer)

```
### https://gist.github.com/gabrielferreirapro/fbec6742d8507bd5cbd953105b626542
$ cd foxitreader/
$ rm lib/libssl.so.10
$ rm lib/libcrypto.so.10
$ ln -s /lib64/libssl.so.10 lib/libssl.so.10
$ ln -s /lib64/libcrypto.so.10 lib/libcrypto.so.10
```
## postman

```
### https://blog.scottlowe.org/2017/11/21/installing-postman-fedora-27/
$ curl -L https://dl.pstmn.io/download/latest/linux64 -o postman-linux-x64.tar.gz
$ tar xzvf postman-linux-x64.tar.gz
$ rm postman-linux-x64.tar.gz
$ ln -s  ~/tool/Postman/Postman ~/bin/postman

###not working anymore
$ vi ~/.local/share/applications/postman.desktop
[Desktop Entry]
Name=Postman
GenericName=API Client
X-GNOME-FullName=Postman API Client
Comment=Make and view REST API calls and responses
Keywords=api;
Exec=~/tool/Postman/postman
Terminal=false
Type=Application
Icon=~/tool/Postman/app/resources/app/assets/icon.png
Categories=Development;Utilities;

```

## black screen after suspend

[bz1645678](https://bugzilla.redhat.com/show_bug.cgi?id=1645678): `Ctrl+Alt+F2` and then `Ctrl+Alt+F1`.


## bluejeans

```
###https://www.bluejeans.com/downloads#plugindesktop
$ sudo yum install https://swdl.bluejeans.com/desktop/linux/1.37/1.37.22/bluejeans-1.37.22.x86_64.rpm
```

## Useful command

```
### check kernel version
$ uname -r
4.18.16-300.fc29.x86_64

### check which window manager is running
$ env | grep -i gdmsession
GDMSESSION=gnome-classic

### check if wayland is running
$ loginctl
SESSION  UID USER     SEAT  TTY 
      2 1000 hongkliu seat0 tty2

$ loginctl show-session 2 -p Type
Type=wayland


### speedtest cli: https://askubuntu.com/questions/104755/how-to-check-internet-speed-via-terminal
$ pip install speedtest-cli
$ speedtest-cli --version
2.0.2
$ speedtest-cli --simple 
Ping: 13.826 ms
Download: 792.22 Mbit/s
Upload: 518.96 Mbit/s


```