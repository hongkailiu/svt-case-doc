# iptables

* [man page](http://ipset.netfilter.org/iptables.man.html)

tables, chains, rules, targets

```sh
# iptables -L
Chain INPUT (policy ACCEPT)
target     prot opt source               destination
ACCEPT     tcp  --  anywhere             anywhere             tcp dpt:websm ctstate NEW

Chain FORWARD (policy DROP)
target     prot opt source               destination
DOCKER-ISOLATION  all  --  anywhere             anywhere
DOCKER     all  --  anywhere             anywhere
ACCEPT     all  --  anywhere             anywhere             ctstate RELATED,ESTABLISHED
ACCEPT     all  --  anywhere             anywhere
ACCEPT     all  --  anywhere             anywhere

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination

Chain DOCKER (1 references)
target     prot opt source               destination

Chain DOCKER-ISOLATION (1 references)
target     prot opt source               destination
RETURN     all  --  anywhere             anywhere
```

Tests:

```sh
### List the rule of chain OUTPUT
# iptables -L OUTPUT
Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination

### append chain OUTPUT with the rule for destination management.azure.com and target DROP
# iptables -A OUTPUT -d management.azure.com -j DROP

# iptables -L OUTPUT
Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination
DROP       all  --  anywhere             13.91.242.34
```

How come the destination becomes `13.91.242.34`.

```sh
# dig +short management.azure.com
arm-rpfd-prod.trafficmanager.net.
westus.management.azure.com.
rpfd-prod-by-01.cloudapp.net.
13.91.242.34
```

Then verify

```sh
# ping -c 1 management.azure.com
PING rpfd-prod-by-01.cloudapp.net (13.91.242.34) 56(84) bytes of data.
ping: sendmsg: Operation not permitted
```

Another example from [OCP-18757](https://polarion.engineering.redhat.com/polarion/#/project/OSE/workitem?id=OCP-18757)

```sh
# iptables -I OUTPUT -p tcp -m string --string ".amazonaws.com" --algo kmp -j DROP
```

* -p, --protocol: The protocol of the rule or of the packet to check.
* -m, --match: Specifies a match to use, that is, an extension module that tests for a specific property.

Then check the string module

```sh
# man iptables-extensions
...
string
       This modules matches a given string by using some pattern matching strategy. It requires a linux kernel >= 2.6.14.

       --algo {bm|kmp}
              Select the pattern matching strategy. (bm = Boyer-Moore, kmp = Knuth-Pratt-Morris)

       [!] --string pattern

```