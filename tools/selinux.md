# SELinux

## Doc

* [introduction](https://www.digitalocean.com/community/tutorials/an-introduction-to-selinux-on-centos-7-part-1-basic-concepts)
* [selinux@rhel](https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/SELinux_Users_and_Administrators_Guide/)
* [selinux@centos](https://wiki.centos.org/HowTos/SELinux)
* others: [1](http://www.techrepublic.com/blog/linux-and-open-source/practical-selinux-for-the-beginner-contexts-and-labels/), [2](https://wiki.gentoo.org/wiki/SELinux/Tutorials)


## Security Context (SC)

### File SC

```sh
# ls -Z /etc/httpd/conf/httpd.conf 
-rw-r--r--. root root system_u:object_r:httpd_config_t:s0 /etc/httpd/conf/httpd.conf
```

Security context label: <code>system_u:object_r:httpd_config_t:s0</code>

| A              | B           |
|----------------|-------------|
| system_u       | user        |
| object_r       | role        |
| httpd_config_t | type        |
| s0             | sensitivity |


## Process SC

```sh
# ps -efZ | grep httpd
system_u:system_r:httpd_t:s0    root      2414     1  0 15:31 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
```

Security context label: <code>system_u:system_r:httpd_t:s0</code>

| A              | B           |
|----------------|-------------|
| system_u       | user        |
| system_r       | role        |
| httpd_t        | domain      |
| s0             | sensitivity |

