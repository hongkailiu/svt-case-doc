### From Elko's email


what can we do to extend what you've done?

  * Use templates above and improve where necessary, I used them very much to create easily many pods with pv/pvc from storage via dynamic provisioning.

  * we have to make all this working with .go version of clusterloader ... :)

I have also script which is in workinprogress phase

https://github.com/ekuric/openshift/tree/master/cns/check_pods

which can extract times when pod/pv/pvc was created. My idea behind this was to see how long it takes for pods when using different storage backends to start and mount pv/pvc.

https://github.com/ekuric/openshift/blob/master/cns/check_pods/check_pvpods_README.adoc 

Further, plan is to test cns with block storage

- https://github.com/obnoxxx/gluster-kubernetes/blob/636342d2fb5db54e6788528e1185ee5d2f9ed01b/docs/design/gluster-block-provisioning.md 
- trello card https://trello.com/c/nKn28CAE/546-5-scale37-ocp-performance-testing-of-cns-block-storage-pv-feature 
- gluster block provision demo : https://asciinema.org/a/132732

My plan is to test metrics with block storage ( storage for cassandra ) in next weeks.

Also here is list of some BZ I opened in past and related to cns.

https://docs.google.com/document/d/1NwyfGsJmzcaGxCuKYG0J8dJgEXTEBpQ1k4l_0QGVTf4/edit#heading=h.3q8egzovffst 


Network of CNS: http://post-office.corp.redhat.com/archives/aos-devel/2017-August/msg00710.html