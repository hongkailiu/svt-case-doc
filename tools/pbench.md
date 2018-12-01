# [pbench](https://github.com/distributed-system-analysis/pbench)

## Doc

* [pbench](http://distributed-system-analysis.github.io/pbench/) and [pbench-doc](http://distributed-system-analysis.github.io/pbench/doc/)
* [pbench-agent: user guide](http://distributed-system-analysis.github.io/pbench/pbench-agent.html)
* [pbench-fio](https://github.com/distributed-system-analysis/pbench/blob/master/agent/bench-scripts/pbench-fio.md): [ipos wiki](https://en.wikipedia.org/wiki/IOPS), [ipos, throughput, and latency](http://searchsolidstatestorage.techtarget.com/definition/IOPS-Input-Output-Operations-Per-Second), [stddevpct](http://help.mastock.michelmontagne.com/Indicateurs/CustomIndicators/keywordshelp/customIndicsstdDevPct/index.html), and [lat, clat, slat](https://linux.die.net/man/1/fio)
* [pbench-uperf](https://github.com/distributed-system-analysis/pbench/blob/master/agent/bench-scripts/pbench-uperf.md)

## Installation

### [Server](http://distributed-system-analysis.github.io/pbench/doc/server/installation.html)
### [Client](http://distributed-system-analysis.github.io/pbench/doc/agent/installation.html)

```sh
# #install pbench-agent
$ wget https://copr.fedorainfracloud.org/coprs/ndokos/pbench/repo/fedora-26/ndokos-pbench-fedora-26.repo
$ sudo mv ndokos-pbench-fedora-26.repo /etc/yum.repos.d/
```

## Use pbench in the test

### Get nodes list

```sh
# oc get nodes
NAME                                          STATUS                     AGE       VERSION
ip-172-31-19-228.us-west-2.compute.internal   Ready                      9m        v1.6.1+5115d708d7
ip-172-31-20-24.us-west-2.compute.internal    Ready                      9m        v1.6.1+5115d708d7
ip-172-31-45-92.us-west-2.compute.internal    Ready                      9m        v1.6.1+5115d708d7
ip-172-31-58-220.us-west-2.compute.internal   Ready,SchedulingDisabled   9m        v1.6.1+5115d708d7
```

### Register
If run on master, register.sh will include itself automatically. So just list nodes other than master.

```sh
# svt/openshift_scalability/pbench-register.sh ip-172-31-19-228.us-west-2.compute.internal \
    ip-172-31-20-24.us-west-2.compute.internal \
    ip-172-31-45-92.us-west-2.compute.internal
```

### Start

```sh
# pbench-start-tools --dir=/var/lib/pbench-agent/hk-conc-scale-a
```

### Run test

### Stop, post-process, and copy

```sh
# pbench-stop-tools --dir=/var/lib/pbench-agent/hk-conc-scale-a
# pbench-postprocess-tools --dir=/var/lib/pbench-agent/hk-conc-scale-a
# pbench-copy-results
```

### Check if the results are uploaded

The results should show up in 10-15 mins on the [server](http://pbench.perf.lab.eng.bos.redhat.com/results/).
Important stats: sar (cpu & mem) and iostat folder.

### Clean up before Rerun
To run pbench again, no need to register the tools again, but you should run <code>pbench-clear-results</code> on _EVERY_ node.

## Read the stats from pbench

Example of pbench stats is [here](http://pbench.perf.lab.eng.bos.redhat.com/results/EC2::ip-172-31-58-220/).

### [sar](https://linux.die.net/man/1/sar)

CPU, Memory, Network, ...

[command examples](https://www.ibm.com/support/knowledgecenter/en/ssw_aix_61/com.ibm.aix.cmds5/sar.htm)

```sh
# sar -A 10
```

### [pidstat](https://linux.die.net/man/1/pidstat)

[command examples](http://www.thegeekstuff.com/2014/11/pidstat-examples/)

```sh
# pidstat  -l -w -u -h -d -r  -p ALL  10
```

### [iostat](https://linux.die.net/man/1/iostat)

[command examples](http://www.thegeekstuff.com/2011/07/iostat-vmstat-mpstat-examples/)

```sh
# iostat  -N -t -y -x -m 10
Linux 3.10.0-774.el7.x86_64 (ip-172-31-24-121.us-west-2.compute.internal) 	12/01/17 	_x86_64_	(4 CPU)

12/01/17 17:30:16
avg-cpu:  %user   %nice %system %iowait  %steal   %idle
          14.45    0.00    2.85    0.69    0.13   81.89

Device:         rrqm/s   wrqm/s     r/s     w/s    rMB/s    wMB/s avgrq-sz avgqu-sz   await r_await w_await  svctm  %util
xvda              0.00     0.10   47.40   54.20     3.13     0.32    69.38     0.14    1.41    0.96    1.80   0.50   5.05
xvdb              0.00     0.00    0.00    0.00     0.00     0.00     0.00     0.00    0.00    0.00    0.00   0.00   0.00
```

pbench uses iostat with <code>-x</code>, ie, extended statistics as the output. The values shows in the stats graphs are:

* IOPS: <code>r/s</code> and <code>w/s</code>
* Throughput_MB_per_sec: <code>rMB/s</code> and <code>wMB/s</code>

Understand the output: [1](https://coderwall.com/p/utc42q/understanding-iostat), [2](http://www.thegeekstuff.com/2011/07/iostat-vmstat-mpstat-examples/?utm_source=feedburner), [3](https://coderwall.com/p/utc42q/understanding-iostat).

* avgrq-sz: The average size (in sectors) of the requests that were issued to the device. [How to find the
sector size](https://unix.stackexchange.com/questions/2668/finding-the-sector-size-of-a-partition):

```sh
$ sudo fdisk -l
Disk /dev/xvda: 30 GiB, 32212254720 bytes, 62914560 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0xc006e828

Device     Boot Start      End  Sectors Size Id Type
/dev/xvda1 *     2048 62914559 62912512  30G 83 Linux
```

So "Request_Size_in_512_byte_sectors" is one of titles of pbench graphs.


### [pprof](https://github.com/google/pprof)

## Run pbench for one node only

After ssh to that node:

```sh
# vi ~/svt/openshift_scalability/pbench-register.sh
pbench-register-tool --name=pprof -- --osecomponent=node
```

Note that the value of <code>--osecomponent</code> is either _master_ or _node_, up to the role
of the node where we want to run pbench.


## [pbench-fio](https://github.com/distributed-system-analysis/pbench/blob/master/agent/bench-scripts/pbench-fio.md)

A wrapper application of [fio.md](fio.md).

### Understand pbench-fio data

#### Time unit

1 second (s) = 10^3 milliseconds (ms) = 10^6 microseconds (μs) = 10^9 nanoseconds (ns)

#### Server and client data on pbench-fio:

* server throughput: sum of all clients' throughput
* server latency: average of all clients' latency

### some reverse engineering on pbench-fio

```sh
### Do our test as usual
# pbench-fio --test-types=randrw --clients=172.21.0.10 --config=RAND_IO_300s --samples=1 --max-stddev=20 --block-sizes=16 --job-file=config/random_io.job --pre-iteration-script=/root/svt/storage/scripts/drop-cache.sh
pbench-fio: package version is missing in config file
### This is new to me~~!

# which pbench-fio
/opt/pbench-agent/bench-scripts/pbench-fio

# grep "missing in" /opt/pbench-agent/bench-scripts/pbench-fio -n
22:	echo "pbench-fio: package version is missing in config file" > /dev/tty

$ git blame agent/bench-scripts/pbench-fio | grep 22 | grep missing
b66608349 agent/bench-scripts/pbench-fio (Nick Dokos                 2018-02-01 15:24:22 -0500  22) 	echo "pbench-fio: package version is missing in config file" > /dev/tty

$ git tag --contains b66608349
v0.48

### Get pbench version
# rpm -qa | grep pbench-agent
pbench-agent-0.47-164gb666083.noarch
### So it looks like it is with version 4.7
### Checking on release notes: http://distributed-system-analysis.github.io/pbench/doc/release-notes/RELEASE-NOTES.html
### version 4.8: "moving some default setting from the pbench-fio script to the config file"
### So we are with 4.7 ... should not worry about 4.8 features ... until I found out ...

$ git log --oneline
87190caa Bump the version to v0.48
172bbcbb index-pbench: Add unit tests
f7fe1884 index-pbench: hostname impedance matching with tools
e2e4c9f1 index-pbench: add results mapping and convert ts values to float
e9e9d6c7 pbench-move-unpacked: do not create spurious links
b6660834 pbench-fio: put defaults in config file
...

$ git log show b6660834
...
--- a/agent/bench-scripts/samples/pbench-agent.cfg
+++ b/agent/bench-scripts/samples/pbench-agent.cfg
@@ -1,3 +1,7 @@
 [packages]
 pandas-package = python2-pandas
 
+[pbench-fio]
+version = 3.3
+histogram_interval_msec = 10000

### Add those line to the pbench-config
# vi /opt/pbench-agent/config/pbench-agent.cfg
...
# pandas-package = python2-pandas

[pbench-fio]
version = 3.3
histogram_interval_msec = 10000

### Rerun the test
# pbench-fio --test-types=randrw --clients=172.21.0.10 --config=RAND_IO_300s --samples=1 --max-stddev=20 --block-sizes=16 --job-file=config/random_io.job --pre-iteration-script=/root/svt/storage/scripts/drop-cache.sh
[error][2018-02-08T20:15:41.353368406] [check_install_rpm] the installation of pbench-fio-3.3 failed

# yum info pbench-fio
### returns me 2.14 is the latest version
```



Looks like pbench-agent-0.47-164gb666083.noarch has the code of commit `b6660834`. Ravi makes the release tag on [pbench-release page](https://github.com/distributed-system-analysis/pbench/releases). Oh~! I know Ravi. Then this is what is in IRC:

```
hongkliu: the reason i asked this is that i feel 0.47 package has code from o.48
ravi: yes, we pull the code from master and build an rpm on a nightly basis
ravi: so that we have the latest fixes
ravi: everything after o.47 - 164g is the sha
hongkliu: have we built pbench-fio 3.3 yet? yum info tells me the latest is 2.14 ... but the installed pbench requires 3.3 ... 
ravi: oh we haven't built a fio 3.3 for the official repo, we just did it for test
ravi: I will quickly build one and let you know
```

After talking to Ravi, evething starts to make sense.
