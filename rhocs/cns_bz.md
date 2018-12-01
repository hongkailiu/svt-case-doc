# CNS bz

## PVC create

* docker:
    * gfs-file: 1000
    * gfs-block: 100 but very slow: [1555062](https://bugzilla.redhat.com/show_bug.cgi?id=1555062)

* crio:
    * gfs-file: 70 [1547731](https://bugzilla.redhat.com/show_bug.cgi?id=1547731) and [1575062](https://bugzilla.redhat.com/show_bug.cgi?id=1575062)
    * gfs-block: 100 but very slow: [1555062](https://bugzilla.redhat.com/show_bug.cgi?id=1555062)

## PVC delete

* docker:
    * gfs-file: 1000 [1430762](https://bugzilla.redhat.com/show_bug.cgi?id=1430762); [1573304](https://bugzilla.redhat.com/show_bug.cgi?id=1573304)
    * gfs-block: NOT test yet since creation does not scale for the above bz

* crio: NOT test yet since creation does not scale for the above bz
