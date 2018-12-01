# IO Benchmark: fio

## Doc

* [fio@github](https://github.com/axboe) and [HOWTO](https://github.com/axboe/fio/blob/master/HOWTO)
* [IOPS, latency, and bandwidth](https://www.violin-systems.com/blog/the-fundamental-characteristics-of-storage/)
* [I/O: Random vs Sequential](https://www.violin-systems.com/blog/understanding-io-random-vs-sequential/)

## Installation

Tested with `Fedora 27` on EC2:

```sh
$ aws ec2 run-instances --image-id ami-959441ed --security-group-ids sg-5c5ace38 \
   --count 1 --instance-type m4.xlarge --key-name id_rsa_perf --subnet subnet-4879292d \
   --block-device-mappings "[{\"DeviceName\":\"/dev/sda1\", \"Ebs\":{\"VolumeSize\": 60, \"VolumeType\": \"gp2\"}}, {\"DeviceName\":\"/dev/sdf\", \"Ebs\":{\"VolumeSize\": 1000, \"VolumeType\": \"gp2\"}}]"     --query 'Instances[*].InstanceId'     --tag-specifications="[{\"ResourceType\":\"instance\",\"Tags\":[{\"Key\":\"Name\",\"Value\":\"qe-hongkliu-fio-test\"}]}]"
```

```sh
# dnf list fio --showduplicates
Last metadata expiration check: 0:00:31 ago on Sat 03 Mar 2018 01:08:42 PM UTC.
Available Packages
fio.x86_64                                                   3.0-3.fc27                                                   fedora

# dnf install -y fio
# which fio
/bin/fio
# fio --version
fio-3.0
```

```sh
# mkfs.xfs /dev/xvdf
# mkdir /data
# echo "/dev/xvdf /data xfs defaults 0 0" >> /etc/fstab
# mount -a
```

## Job params

* bs: The block size in bytes used for I/O units
* size: The total size of file I/O for each thread of this job.
* runtime: Tell fio to terminate processing after the specified period of time.
* ramp_time: If set, fio will run the specified workload for this amount of time before logging any performance numbers.
* startdelay: Delay the start of job for the specified amount of time.
* [stonewall](https://github.com/axboe/fio/blob/master/HOWTO#L2467): Wait for preceding jobs in the job file to exit, before starting this one.
* [ioengine](https://github.com/axboe/fio/blob/master/HOWTO#L1696): Defines how the job issues I/O to the file.
* [iodepth](https://github.com/axboe/fio/blob/master/HOWTO#L2074): Number of I/O units to keep in flight against the file.
* [fsync_on_close=bool](https://github.com/axboe/fio/blob/master/HOWTO#L1226): If true, fio will :manpage:`fsync(2)` a dirty file on close.  This differs from :option:`end_fsync` in that it will happen on every file close, not
	just at the end of the job.  Default: false.
* [direct=bool](https://github.com/axboe/fio/blob/master/HOWTO#L968): If value is true, use non-buffered I/O. This is usually O_DIRECT. Default: false.
* [sync=bool](https://github.com/axboe/fio/blob/master/HOWTO#L1559): Use synchronous I/O for buffered writes. For the majority of I/O engines, this means using O_SYNC. Default: false.
* O_DIRECT and O_SYNC: [link1](https://lwn.net/Articles/457667/), [link2](https://stackoverflow.com/questions/5055859/how-are-the-o-sync-and-o-direct-flags-in-open2-different-alike), [link3](http://www.thesubodh.com/2013/07/what-are-exactly-odirect-osync-flags.html)


## More understanding with tests

```sh
/bin/fio --filesize=500M --runtime=120s --ioengine=libaio --direct=1 --time_based --stonewall --filename=/data/testfile --output=fio.output  \
        --name=sw1m@qd32 --description="Bandwidth via 1MB sequential writes @ qd=32" --iodepth=32 --bs=1m --rw=write
```

`ps -ef | grep fio` shows 2 processes (parent-child) from the above `fio` command, `top` shows that
the parent-pocess is busier.

### [Understand the output](https://tobert.github.io/post/2014-04-17-fio-output-explained.html):

#### [Thoughput]((http://searchstorage.techtarget.com/definition/IOPS-input-output-operations-per-second))
How many units of information a system can process in a period of time.

* Throughput: Size of units that IO operations process per second, eg, 160 MiB/s.
* IOPS: Input/output operations per second, eg, 10,000.
* IO size or block size: the unit each IO operation processes, eg, 16 KiB.

So here the formula is <code>Throughput = block size * IOPS</code>. See stat of [ebs volume types](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EBSVolumeTypes.html).

#### latency
A measure of the length of time it takes for a single I/O request to be completed from the application's point of view. The tool fio measures 3 kinds of latency:

* lat: Total latency. Same names as slat and clat, this denotes the time from when fio created the I/O unit to completion of the I/O operation.
* clat: Completion latency. It denotes the time from submission to completion of the I/O pieces.
* slat: Submission latency. This is the time it took to submit the I/O, meaning "how long did it take to submit this IO to the kernel for processing?".

```sh
# cat fio.output
sw1m@qd32: (g=0): rw=write, bs=(R) 1024KiB-1024KiB, (W) 1024KiB-1024KiB, (T) 1024KiB-1024KiB, ioengine=libaio, iodepth=32
fio-3.0
Starting 1 process

sw1m@qd32: (groupid=0, jobs=1): err= 0: pid=2883: Sat Mar  3 14:50:00 2018
  Description  : [Bandwidth via 1MB sequential writes @ qd=32]
  write: IOPS=90, BW=90.2MiB/s (94.5MB/s)(10.6GiB/120083msec)
    slat (usec): min=30, max=78777, avg=11080.55, stdev=1653.86
    clat (msec): min=10, max=4261, avg=343.79, stdev=305.32
     lat (msec): min=12, max=4273, avg=354.87, stdev=305.40
    clat percentiles (msec):
     |  1.00th=[   78],  5.00th=[   79], 10.00th=[   90], 20.00th=[  112],
     | 30.00th=[  124], 40.00th=[  157], 50.00th=[  359], 60.00th=[  414],
     | 70.00th=[  460], 80.00th=[  506], 90.00th=[  625], 95.00th=[  810],
     | 99.00th=[ 1368], 99.50th=[ 1938], 99.90th=[ 3037], 99.95th=[ 3675],
     | 99.99th=[ 4245]
   bw (  KiB/s): min=87888, max=225280, per=99.76%, avg=92103.65, stdev=8701.22, samples=240
   iops        : min=   85, max=  220, avg=89.88, stdev= 8.51, samples=240
  lat (msec)   : 20=0.03%, 50=0.57%, 100=12.81%, 250=35.89%, 500=29.45%
  lat (msec)   : 750=15.02%, 1000=3.95%, 2000=1.78%, >=2000=0.49%
  cpu          : usr=0.26%, sys=0.56%, ctx=10878, majf=0, minf=9
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=99.7%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.1%, 64=0.0%, >=64=0.0%
     issued rwt: total=0,10827,0, short=0,0,0, dropped=0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=32

Run status group 0 (all jobs):
  WRITE: bw=90.2MiB/s (94.5MB/s), 90.2MiB/s-90.2MiB/s (94.5MB/s-94.5MB/s), io=10.6GiB (11.4GB), run=120083-120083msec

Disk stats (read/write):
  xvdf: ios=0/86478, merge=0/0, ticks=0/7247141, in_queue=7251676, util=99.97%

```

The summary line:

```sh
# grep -E "groupid|IOPS=" fio.output
sw1m@qd32: (groupid=0, jobs=1): err= 0: pid=2883: Sat Mar  3 14:50:00 2018
  write: IOPS=90, BW=90.2MiB/s (94.5MB/s)(10.6GiB/120083msec)
```

* IOPS: 90 write operations/sec
* BW (band width): 90.2MiB/s=94.5MB/s (1MiB=1.04858MB)
* In total, write 10.6GiB in 120083msec, which is 8.827Gib/s (90.4MiB/s), a bit bigger than the printed BW.

### John Strunk's benchmarks

```sh
/bin/fio --filesize=500M --runtime=120s --ioengine=libaio --direct=1 --time_based --stonewall --filename=/data/testfile --output=fio.john.output  \
        --name=sw1m@qd32 --description="Bandwidth via 1MB sequential writes @ qd=32" --iodepth=32 --bs=1m --rw=write \
        --name=sr1m@qd32 --description="Bandwidth via 1MB sequential reads @ qd=32" --iodepth=32 --bs=1m --rw=read \
        --name=rw4k@qd1 --description="e2e latency via 4k random writes @ qd=1" --iodepth=1 --bs=4k --rw=randwrite \
        --name=rr4k@qd1 --description="e2e latency via 4k random reads @ qd=1" --iodepth=1 --bs=4k --rw=randread \
        --name=rw4k@qd32 --description="IOPS via 4k random writes @ qd=32" --iodepth=32 --bs=4k --rw=randwrite \
        --name=rr4k@qd32 --description="IOPS via 4k random reads @ qd=32" --iodepth=32 --bs=4k --rw=randread
```