# RHEL

[system_administrators_guide](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/)

## [Subscription-Manager](https://access.redhat.com/documentation/en-us/red_hat_subscription_management/1/html/quick_registration_for_rhel/)

Target: Installation `buildah` on rhel7

### rhel7 host

Create a RHEL7 instance on aws:

```
# yum info buildah
Loaded plugins: amazon-id, product-id, rhui-lb, search-disabled-repos, subscription-manager
This system is not registered with an entitlement server. You can use subscription-manager to register.
Error: No matching Packages to list

```

Following [this doc](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux_atomic_host/7/html/managing_containers/finding_running_and_building_containers_without_docker#installing_buildah):

```
# subscription-manager repos --enable=rhel-7-server-rpms
Error: 'rhel-7-server-rpms' does not match a valid repository ID. Use "subscription-manager repos --list" to see valid repositories.
# subscription-manager repos --list
This system has no repositories available through subscriptions.

```

Follow [the doc](https://docs.google.com/document/d/14dj5qCPHDlJE4_hs0i0M3yZFoEOrcqguovvajv8R2iY/edit) to make subscription work:

```sh
### get username and password here: https://developers.redhat.com/
### use u/p to do the register
# subscription-manager register
### get the `Pool ID` for `Red Hat Enterprise Linux Developer Suite`
# subscription-manager list --available
# subscription-manager attach --pool=<pool_id>

# subscription-manager repos --enable=rhel-7-server-rpms
Repository 'rhel-7-server-rpms' is enabled for this system.
# subscription-manager repos --enable=rhel-7-server-extras-rpms
# yum -y install buildah
```


### rhel7 container

Run rhel containers on a rhel host with subscription:

```
### https://access.redhat.com/discussions/1405933
# podman run --rm -it -p 8080 registry.access.redhat.com/rhel7/rhel bash
[root@eebaf9cffc35 /]# yum-config-manager --enable rhel-7-server-rpms
[root@eebaf9cffc35 /]# yum-config-manager --enable rhel-7-server-extras-rpms
[root@eebaf9cffc35 /]# yum list buildah
buildah.x86_64                                  1.2-2.gitbe87762.el7                                   rhel-7-server-extras-rpms
```

## [bash-completion](https://www.cyberciti.biz/faq/fedora-redhat-scientific-linuxenable-bash-completion/)

```sh
# yum install bash-completion bash-completion-extras
```

## man

Search in man pages with `man -k <keyword>`:

```sh
$ man -k syslog
logger (1)           - a shell command interface to the syslog(3) system log module
rsyslog.conf (5)     - rsyslogd(8) configuration file
rsyslogd (8)         - reliable and extended syslogd

# man -k journal
coredumpctl (1)      - Retrieve coredumps from the journal
journal-remote.conf (5) - Journal remote service configuration files
journal-remote.conf.d (5) - Journal remote service configuration files
journalctl (1)       - Query the systemd journal
journald.conf (5)    - Journal service configuration files
journald.conf.d (5)  - Journal service configuration files
systemd-cat (1)      - Connect a pipeline or program's output with the journal
systemd-journal-upload (8) - Send journal messages over the network
systemd-journald (8) - Journal service
systemd-journald.service (8) - Journal service
systemd-journald.socket (8) - Journal service
systemd.journal-fields (7) - Special journal fields
```

## yum

### gpgcheck

```sh
### By default, gpgcheck is enabled:
# cat /etc/yum.conf |grep gpg
gpgcheck=1

### backup files in /etc/yum.repo.d/ folder and then delete all the files
# yum-config-manager --add-repo="http://mirror.centos.org/centos/7/os/x86_64"
### not working because of gpg checking
# yum install -y telnet

# man yum | grep gpg
       --nogpgcheck
              Configuration Option: gpgcheck

# yum install -y telnet --nogpgcheck
### or
# vi /etc/yum.repos.d/mirror.centos.org_centos_7_os_x86_64.repo

### Remember to remove the test repo file and recover the backed up ones.
```

### kernel update

```sh
### List availabe versions:
# yum list kernel
Loaded plugins: amazon-id, rhui-lb, search-disabled-repos
Installed Packages
kernel.x86_64                               3.10.0-514.21.2.el7                                @koji-override-0/7.3            
Available Packages
kernel.x86_64                               3.10.0-693.17.1.el7                                rhui-REGION-rhel-server-releases

### Show the current kernel info
# uname -r
3.10.0-514.21.2.el7.x86_64
# yum -y update kernel

# yum list kernel
Loaded plugins: amazon-id, rhui-lb, search-disabled-repos
Installed Packages
kernel.x86_64                               3.10.0-514.21.2.el7                               @koji-override-0/7.3             
kernel.x86_64                               3.10.0-693.17.1.el7                               @rhui-REGION-rhel-server-releases
# reboot

# uname -r
3.10.0-693.17.1.el7.x86_64
```

Set up default starting kernel

```sh
### List all kernel options
# grep ^menuentry /etc/grub2.cfg 
menuentry 'Red Hat Enterprise Linux Server 7.3 Rescue 8a0d989f3520475abcd4869f7dc9875b (3.10.0-693.17.1.el7.x86_64)' --class red --class gnu-linux --class gnu --class os --unrestricted $menuentry_id_option 'gnulinux-3.10.0-514.21.2.el7.x86_64-advanced-00a738da-7c2a-458c-83c0-2420aaed3b8a' {
menuentry 'Red Hat Enterprise Linux Server (3.10.0-693.17.1.el7.x86_64) 7.3 (Maipo)' --class red --class gnu-linux --class gnu --class os --unrestricted $menuentry_id_option 'gnulinux-3.10.0-514.21.2.el7.x86_64-advanced-00a738da-7c2a-458c-83c0-2420aaed3b8a' {
menuentry 'Red Hat Enterprise Linux Server (3.10.0-514.21.2.el7.x86_64) 7.3 (Maipo)' --class red --class gnu-linux --class gnu --class os --unrestricted $menuentry_id_option 'gnulinux-3.10.0-514.21.2.el7.x86_64-advanced-00a738da-7c2a-458c-83c0-2420aaed3b8a' {
menuentry 'Red Hat Enterprise Linux Server (0-rescue-2c0164cc85e344b6837514530c15f0d7) 7.3 (Maipo)' --class red --class gnu-linux --class gnu --class os --unrestricted $menuentry_id_option 'gnulinux-0-rescue-2c0164cc85e344b6837514530c15f0d7-advanced-00a738da-7c2a-458c-83c0-2420aaed3b8a' {

### Set up the desired one
# grub2-set-default 'Red Hat Enterprise Linux Server (3.10.0-514.21.2.el7.x86_64) 7.3 (Maipo)'
```

Remove a kernel: Not easy to get a clean rollback!!!

```sh
### We can only remove kernel versions which is not the one being used.
# yum remove kernel-3.10.0-693.17.1.el7.x86_64 kernel-debug-devel-3.10.0-693.1.1.el7.x86_64 kernel-headers-3.10.0-693.1.1.el7.x86_64
# reboot #maybe unnecessary
# yum list kernel
Loaded plugins: amazon-id, rhui-lb, search-disabled-repos
Installed Packages
kernel.x86_64                               3.10.0-514.21.2.el7                                @koji-override-0/7.3            
Available Packages
kernel.x86_64                               3.10.0-693.17.1.el7                                rhui-REGION-rhel-server-releases
```

`grup2` menu could have some leftovers even the unwanted versions even if the kernel versions are removed.

```sh
###
### NOT tried yet: https://weblog.aklmedia.nl/2014/02/limit-number-of-kernels-in-centos/
# package-cleanup --oldkernels --count=2
### or this might help:
### https://wiki.gentoo.org/wiki/GRUB2_Quick_Start
```

## Logging
logging docs on fedora: [here](https://docs.fedoraproject.org/f27/system-administrators-guide/monitoring-and-automation/Viewing_and_Managing_Log_Files.html).

Logging Services: journald, rsyslogd

```sh
# systemctl list-units | grep syslog
rsyslog.service                                     loaded active running   System Logging Service
# systemctl list-units | grep journal
systemd-journal-flush.service                       loaded active exited    Flush Journal to Persistent Storage
systemd-journald.service                            loaded active running   Journal Service
systemd-journald.socket                             loaded active running   Journal Socket
```


Notice that `journald` have more messages than `rsyslogd`.

|                              | rsyslogd                                | journald                                                                          |
|------------------------------|-----------------------------------------|-----------------------------------------------------------------------------------|
| content                      | Syslog messages                         | Syslog messages, kernel log messages, boot messages, stdin/stderr of all services |
| conf file                    | /etc/rsyslog.conf                       | /etc/rsyslog.conf                                                                 |
| persistent by default        | saved in /var/log folder with logrotate | no                                                                                |
| default message store format | unstructured                            | structured, indexed binary                                                        |
| cli to write                 | logger                                  | logger, systemd-cat                                                               |

Run `logger "test msg 001"`, then we can get log the entry from `tail -f /var/log/messsages` and `journalctl -f` because both of them receive *Syslog messages*. Command `systemd-cat` (eg, `echo test msg 001 | systemd-cat`) writes only to `journald` and since `rsyslogd` is configured to import logs from `journald`, we can see the log entry in both too.

### rsyslog

The conf file `/etc/rsyslog.conf` specify global directives, modules, and rules that consist of filter and action parts.

```sh
###check the following pages for log format
### http://www.rsyslog.com/doc/v8-stable/configuration/templates.html
### http://www.rsyslog.com/doc/master/configuration/properties.html
# grep " format" /etc/rsyslog.conf -A1
# Use default timestamp format
$ActionFileDefaultTemplate RSYSLOG_TraditionalFileFormat
# grep "secure" /etc/rsyslog.conf 
authpriv.*                                              /var/log/secure
# head -n 1 /var/log/secure
Jan 29 19:22:54 ip-172-31-21-62 sshd[2197]: reverse mapping checking getaddrinfo for hn.kd.ny.adsl [125.44.139.5] failed - POSSIBLE BREAK-IN ATTEMPT!
```

Add a rule for debug:

```sh
# echo "*.debug /var/log/messages-debug" > /etc/rsyslog.d/debug.conf
# systemctl restart rsyslog.service
# logger -p user.debug "debug by me"
# tail -f /var/log/messages
...
Feb  4 10:24:13 ip-172-31-21-62 ec2-user: debug by me
```

Log rotation:

```sh
# ll /var/log/messages*
-rw-------. 1 root root   3339 Feb  4 11:01 /var/log/messages
-rw-------. 1 root root 305441 Sep 18 11:16 /var/log/messages-20170918
-rw-------. 1 root root 371124 Sep 27 09:31 /var/log/messages-20170927
-rw-------. 1 root root 224415 Jan 29 19:19 /var/log/messages-20180129
-rw-------. 1 root root 288795 Feb  4 10:27 /var/log/messages-20180204

### /etc/logrotate.conf has the default log-rotation settings.
# cat  /etc/logrotate.d/syslog 
/var/log/cron
/var/log/maillog
/var/log/messages
/var/log/secure
/var/log/spooler
{
    missingok
    sharedscripts
    postrotate
	/bin/kill -HUP `cat /var/run/syslogd.pid 2> /dev/null` 2> /dev/null || true
    endscript
}

```

### journald

```sh
# journalctl | tail -1
Feb 04 15:10:06 ip-172-31-21-62.us-west-2.compute.internal systemd[1]: Starting Session 8 of user ec2-user.
```

The fields from `journald` look quite similar to ones from `rsyslogd`. How to use `journalctl` to filter out logs is shown [here](https://docs.fedoraproject.org/f27/system-administrators-guide/monitoring-and-automation/Viewing_and_Managing_Log_Files.html#s1-Using_the_Journal).

### [Interaction between journald and rsyslogd](https://docs.fedoraproject.org/f27/system-administrators-guide/monitoring-and-automation/Viewing_and_Managing_Log_Files.html#s1-interaction_of_rsyslog_and_journal)

By default, `rsyslogd` is configured to import logs from `journald`:

```sh
# grep -i journal /etc/rsyslog.conf | grep "^[^#;]"
$ModLoad imjournal # provides access to the systemd journal
$IMJournalStateFile imjournal.state
```

## NTP

```sh
### show status
# timedatectl status
### set timezone: temporarily
# tzselect
### set timezone: permanently
# timedatectl set-timezone America/Toronto
### set up ntp
### check https://chrony.tuxfamily.org/manual.html for more configuration.
# vi /etc/chrony.conf
server <npt_server_name> iburst
...
# timedatectl set-ntp true
# systemctl restart chronyd.service
### Check ntp server in usage
# chronyc sources -v
```

## Firewall

netfilter, iptables, firewalld

```
### tested on rhel
# yum list iptables firewalld
# systemctl status iptables firewalld
### probably iptables and firewalld should not work at the same time
```

[iptables](iptables.md)

## top command

* [top output](https://tecadmin.net/understanding-linux-top-command-results-uses/)
* other tools like top: [Monitoring: top vs atop vs htop vs iftop vs iotop vs glances](https://www.youtube.com/watch?v=KE1fqZRX9mg)


## [Virtual Machine Manager](https://virt-manager.org/)

* [libvirt](https://libvirt.org/) and [virsh](https://libvirt.org/virshcmdref.html)


## More reading

* [Syslog messages and Syslog protocol](https://blog.rapid7.com/2017/05/24/what-is-syslog/)



