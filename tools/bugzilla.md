# [Bugzilla](https://bugzilla.redhat.com)

## Use google search

Try to search it in bugzilla using google with <code>site:bugzilla.redhat.com keywords</code>.

For instance, we see those error when running installation playbook:

```
2017-07-19 12:24:43,339 p=11112 u=root |  PLAY RECAP *********************************************************************
2017-07-19 12:24:43,339 p=11112 u=root |  ec2-34-212-25-230.us-west-2.compute.amazonaws.com : ok=631  changed=167  unreachable=0    failed=1   
2017-07-19 12:24:43,339 p=11112 u=root |  ec2-54-186-193-169.us-west-2.compute.amazonaws.com : ok=235  changed=52   unreachable=0    failed=0   
2017-07-19 12:24:43,339 p=11112 u=root |  ec2-54-187-252-111.us-west-2.compute.amazonaws.com : ok=235  changed=52   unreachable=0    failed=0   
2017-07-19 12:24:43,339 p=11112 u=root |  ec2-54-190-23-19.us-west-2.compute.amazonaws.com : ok=235  changed=52   unreachable=0    failed=0   
2017-07-19 12:24:43,339 p=11112 u=root |  localhost                  : ok=12   changed=0    unreachable=0    failed=0   
2017-07-19 12:24:43,340 p=11112 u=root |  Failure summary:

2017-07-19 12:24:43,340 p=11112 u=root |    1. Host:     ec2-34-212-25-230.us-west-2.compute.amazonaws.com
2017-07-19 12:24:43,340 p=11112 u=root |       Play:     Create Hosted Resources
2017-07-19 12:24:43,340 p=11112 u=root |       Task:     openshift_default_storage_class : Ensure storageclass object
2017-07-19 12:24:43,340 p=11112 u=root |       Message:  unsupported parameter for module: kind
```

Then in Google, search with <code>site:bugzilla.redhat.com unsupported parameter for module: kind</code>.

In Bugzilla](https://bugzilla.redhat.com), search for it.

In the end, you may find [this bug](https://bugzilla.redhat.com/show_bug.cgi?id=1472741) out.
