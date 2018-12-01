# [CNS S3](https://access.redhat.com/documentation/en-us/red_hat_gluster_storage/3.3/html-single/container-native_storage_for_openshift_container_platform/#S3_Object_Store)

## Installation

```sh
# cns-deploy topology.json --deploy-gluster  --namespace storage-project --yes --log-file=/tmp/444-cns-deploy.log --object-account testvolume --object-user adminuser --object-password itsmine --verbose

# oc get pvc
NAME                    STATUS    VOLUME                                     CAPACITY   ACCESSMODES   STORAGECLASS       AGE
gluster-s3-claim        Bound     pvc-db246425-bfe6-11e7-a214-02777ccf87f4   2Gi        RWX           glusterfs-for-s3   1h
gluster-s3-meta-claim   Bound     pvc-db260419-bfe6-11e7-a214-02777ccf87f4   1Gi        RWX           glusterfs-for-s3   1h
root@ip-172-31-16-118: ~ # oc get route 
NAME               HOST/PORT                                                       PATH      SERVICES             PORT      TERMINATION   WILDCARD
gluster-s3-route   gluster-s3-route-storage-project.apps.1102-nk6.qe.rhcloud.com             gluster-s3-service   <all>                   None

```

## Check with object operations

```sh
$ wget http://s3.amazonaws.com/doc/s3-example-code/s3-curl.zip
$ sudo dnf install perl-Digest-HMAC
$ vi ~/.s3curl
%awsSecretAccessKeys = (
    # personal account
    personal => {
        id => 'testvolume:adminuser',
        key => 'itsmine',
    },

    # corporate account
    company => {
        id => 'secret',
        key => 'secret',
    },
);

$ chmod 700 s3curl.pl
### Add 'gluster-s3-route-storage-project.apps.1103-ov3.qe.rhcloud.com' into endpoints
$ vi s3curl.pl
my @endpoints = ( 's3.amazonaws.com',
                  'gluster-s3-route-storage-project.apps.1102-nk6.qe.rhcloud.com',
                  ...

### Create a bucket
$ s3curl.pl --id "personal" --createBucket -- http://gluster-s3-route-storage-project.apps.1102-nk6.qe.rhcloud.com/bkt-hk -v
### List buckets
$ s3curl.pl --id "personal"  -- http://gluster-s3-route-storage-project.apps.1103-ov3.qe.rhcloud.com/bkt-hk 
<?xml version='1.0' encoding='UTF-8'?>
<ListBucketResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Name>bkt-hk</Name><Prefix/><Marker/><MaxKeys>1000</MaxKeys><IsTruncated>false</IsTruncated></ListBucketResult>
```

More examples are [here](https://github.com/gluster/gluster-kubernetes/tree/master/docs/examples/gluster-s3-storage-template#testing).
