# Network Basics

## Doc

* [Understanding IP Addresses, Subnets, and CIDR Notation for Networking](https://www.digitalocean.com/community/tutorials/understanding-ip-addresses-subnets-and-cidr-notation-for-networking)

## View

```bash
$ nmcli device 
DEVICE  TYPE      STATE      CONNECTION 
eth0    ethernet  connected  eth0       
lo      loopback  unmanaged  --       

$ nmcli device show eth0 
GENERAL.DEVICE:                         eth0
GENERAL.TYPE:                           ethernet
GENERAL.HWADDR:                         52:54:00:29:41:AA
GENERAL.MTU:                            1500
GENERAL.STATE:                          100 (connected)
GENERAL.CONNECTION:                     eth0
GENERAL.CON-PATH:                       /org/freedesktop/NetworkManager/ActiveConnection/1
WIRED-PROPERTIES.CARRIER:               on
IP4.ADDRESS[1]:                         192.168.122.61/24
IP4.GATEWAY:                            192.168.122.1
IP4.ROUTE[1]:                           dst = 0.0.0.0/0, nh = 192.168.122.1, mt = 100
IP4.ROUTE[2]:                           dst = 192.168.122.0/24, nh = 0.0.0.0, mt = 100
IP4.DNS[1]:                             192.168.122.1
IP6.ADDRESS[1]:                         fe80::64a7:5462:5e82:3772/64
IP6.GATEWAY:                            --
IP6.ROUTE[1]:                           dst = ff00::/8, nh = ::, mt = 256, table=255
IP6.ROUTE[2]:                           dst = fe80::/64, nh = ::, mt = 256
IP6.ROUTE[3]:                           dst = fe80::/64, nh = ::, mt = 100

$ nmcli connection show 
NAME  UUID                                  TYPE      DEVICE 
eth0  ebace513-8c46-42e8-910f-4c0d2052e502  ethernet  eth0   
$ nmcli connection show eth0 
### `ipv4.method:                            auto` in the output of the above command
### indicates that the ip is from dhcp

$ cat /etc/sysconfig/network-scripts/ifcfg-eth0 
TYPE="Ethernet"
PROXY_METHOD="none"
BROWSER_ONLY="no"
BOOTPROTO="dhcp"
DEFROUTE="yes"
IPV4_FAILURE_FATAL="no"
IPV6INIT="yes"
IPV6_AUTOCONF="yes"
IPV6_DEFROUTE="yes"
IPV6_FAILURE_FATAL="no"
IPV6_ADDR_GEN_MODE="stable-privacy"
NAME="eth0"
UUID="ebace513-8c46-42e8-910f-4c0d2052e502"
DEVICE="eth0"
ONBOOT="yes"


```

## Configure static ip

```bash
# nmcli connection add con-name lab ifname eth0 type ethernet ip4 192.168.122.133/24 gw4 192.168.122.1
# nmcli connection modify lab ipv4.method manual
# nmcli connection modify lab ipv4.dns 8.8.8.8
# nmcli connection modify lab connection.autoconnect yes
# nmcli connection modify eth0 connection.autoconnect no

# reboot
# if ip addr have returned both the old and the new ip
# ip addr del <old_ip>/24 dev eth0

###restart commands
# nmcli connection reload
# nmcli connection down eth0
# nmcli connection up eth0
# systemctl restart network.service

```

## set hostname

```bash
# hostnamectl set-hostname master.lab.hongkliu.com
[root@master ~]# cat /etc/hostname 
master.lab.hongkliu.com

```

## nc

```bash
# yum install nmap-ncat
### closed
$ nc -w 2 -v 192.168.122.133 52
Ncat: Version 6.40 ( http://nmap.org/ncat )
Ncat: No route to host.

### open
$ nc -w 2 -v 192.168.122.133 53
Ncat: Version 6.40 ( http://nmap.org/ncat )
Ncat: Connected to 192.168.122.133:53.

```