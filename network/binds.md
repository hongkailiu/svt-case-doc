

https://www.unixmen.com/setting-dns-server-centos-7/
https://www.digitalocean.com/community/tutorials/how-to-configure-bind-as-a-private-network-dns-server-on-centos-7
https://www.techinformant.in/dns-server-configuration-on-rhelcentos-7/

https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/5/html/deployment_guide/ch-bind


```bash
### setup static ip add: 192.168.122.133/24 with dns 8.8.8.8
# hostname
master.lab.hongkliu.com

```

```bash
# yum install bind bind-utils

### modify /etc/named.conf
# cat /etc/named.conf | grep -E "127|query"
  	listen-on port 53 { 127.0.0.1;192.168.122.133; };
  	allow-query     { localhost;192.168.122.0/24; };

# tail -n 2 /etc/named.conf 
include "/etc/named/named.conf.local";

# cat /etc/named/named.conf.local
zone "lab.hongkliu.com" {
    type master;
    file "/etc/named/zones/master.lab.hongkliu.com"; # zone file path
};

zone "122.168.192.in-addr.arpa" {
    type master;
    file "/etc/named/zones/master.192.168.122";  # 10.128.0.0/16 subnet
};

# cat /etc/named/zones/master.192.168.122 
$TTL 86400
@   IN  SOA     master.lab.hongkliu.com. root.lab.hongkliu.com. (
        2011071001  ;Serial
        3600        ;Refresh
        1800        ;Retry
        604800      ;Expire
        86400       ;Minimum TTL
)
@       IN  NS          master.lab.hongkliu.com.
@       IN  PTR         master.lab.hongkliu.com.
master.lab.hongkliu.com.       IN  A   192.168.122.133
133     IN PTR          master.lab.hongkliu.com.

# cat /etc/named/zones/master.lab.hongkliu.com 
$TTL 86400

@       IN  SOA     master.lab.hongkliu.com. root.lab.hongkliu.com. (
        2011071001  ;Serial
        3600        ;Refresh
        1800        ;Retry
        604800      ;Expire
        86400       ;Minimum TTL
        )

@       IN  NS          master.lab.hongkliu.com.
@       IN  A           192.168.122.133

master.lab.hongkliu.com.       IN  A   192.168.122.133
*.apps.master.lab.hongkliu.com.         IN      CNAME   master.lab.hongkliu.com.

### checking
# named-checkconf
# named-checkzone lab.hongkliu.com /etc/named/zones/master.lab.hongkliu.com
# named-checkzone lab.hongkliu.com /etc/named/zones/master.192.168.122

# firewall-cmd --permanent --add-port=53/tcp --zone=public
# firewall-cmd --permanent --add-port=53/udp --zone=public
# firewall-cmd --reload

# restorecon -rv /var/named
# restorecon /etc/named.conf

# sudo systemctl start named
# sudo systemctl enable named

### lab is the name of the active connection
# nmcli connection modify lab ipv4.dns 192.168.122.133

# reboot

```

Debugging command with `dig` and `nslookup`

```bash
$ nslookup google.com 192.168.122.133
$ nslookup bbb.apps.master.lab.hongkliu.com 192.168.122.133

$ dig @192.168.122.133 google.com

```
