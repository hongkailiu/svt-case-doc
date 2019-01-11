# install output

## 20190111

```
$ oc adm release info --pullspecs registry.svc.ci.openshift.org/ocp/release:4.0.0-0.nightly-2019-01-11-205323 | grep installer
  installer                                     registry.svc.ci.openshift.org/ocp/4.0-art-latest-2019-01-11-205323@sha256:58b5bc0f10caa359d520b7ee2cf695b60c1971d3c141abe99d33b8e024ef114f
[fedora@ip-172-31-32-37 ~]$ export ID=$(docker create registry.svc.ci.openshift.org/ocp/4.0-art-latest-2019-01-11-205323@sha256:58b5bc0f10caa359d520b7ee2cf695b60c1971d3c141abe99d33b8e024ef114f)
Unable to find image 'registry.svc.ci.openshift.org/ocp/4.0-art-latest-2019-01-11-205323@sha256:58b5bc0f10caa359d520b7ee2cf695b60c1971d3c141abe99d33b8e024ef114f' locally
Trying to pull repository registry.svc.ci.openshift.org/ocp/4.0-art-latest-2019-01-11-205323 ... 
sha256:58b5bc0f10caa359d520b7ee2cf695b60c1971d3c141abe99d33b8e024ef114f: Pulling from registry.svc.ci.openshift.org/ocp/4.0-art-latest-2019-01-11-205323
23113ae36f8e: Already exists
d134b18b98b0: Already exists
7f71504ac0d8: Already exists
f6218f2a5bb4: Already exists
Digest: sha256:58b5bc0f10caa359d520b7ee2cf695b60c1971d3c141abe99d33b8e024ef114f
Status: Downloaded newer image for registry.svc.ci.openshift.org/ocp/4.0-art-latest-2019-01-11-205323@sha256:58b5bc0f10caa359d520b7ee2cf695b60c1971d3c141abe99d33b8e024ef114f
[fedora@ip-172-31-32-37 ~]$ docker cp $ID:/usr/bin/openshift-install .
[fedora@ip-172-31-32-37 ~]$ docker rm $ID
4150f9952a40391aea8be2b206539f26fa34fec85958a703aa2ef1ba77c99525
[fedora@ip-172-31-32-37 ~]$ ./openshift-install version
./openshift-install v4.0.0-0.130.0.0-dirty
[fedora@ip-172-31-32-37 ~]$ export OPENSHIFT_INSTALL_RELEASE_IMAGE_OVERRIDE=registry.svc.ci.openshift.org/ocp/release:4.0.0-0.nightly-2019-01-11-205323
[fedora@ip-172-31-32-37 ~]$ ./openshift-install create cluster --dir=./20190111.vikas
? SSH Public Key /home/fedora/.ssh/libra.pub
? Platform aws
? Region us-east-2
? Base Domain qe.devcluster.openshift.com
? Cluster Name hongkliu
? Pull Secret [? for help] *************************************************************************************************WARNING Found override for ReleaseImage. Please be warned, this is not advised 
INFO Creating cluster...                          
INFO Waiting up to 30m0s for the Kubernetes API... 
INFO API v1.11.0+f67f40dbad up                    
INFO Waiting up to 30m0s for the bootstrap-complete event... 
ERROR: logging before flag.Parse: E0111 21:20:58.208724    7703 streamwatcher.go:109] Unable to decode an event from the watch stream: http2: server sent GOAWAY and closed the connection; LastStreamID=3, ErrCode=NO_ERROR, debug=""
WARNING RetryWatcher - getting event failed! Re-creating the watcher. Last RV: 2465 
WARNING Failed to connect events watcher: Get https://hongkliu-api.qe.devcluster.openshift.com:6443/api/v1/namespaces/kube-system/events?resourceVersion=2465&watch=true: dial tcp 18.224.160.22:6443: connect: connection refused 
WARNING Failed to connect events watcher: Get https://hongkliu-api.qe.devcluster.openshift.com:6443/api/v1/namespaces/kube-system/events?resourceVersion=2465&watch=true: dial tcp 3.17.31.218:6443: connect: connection refused 
WARNING Failed to connect events watcher: Get https://hongkliu-api.qe.devcluster.openshift.com:6443/api/v1/namespaces/kube-system/events?resourceVersion=2465&watch=true: dial tcp 52.15.99.239:6443: connect: connection refused 
WARNING Failed to connect events watcher: Get https://hongkliu-api.qe.devcluster.openshift.com:6443/api/v1/namespaces/kube-system/events?resourceVersion=2465&watch=true: dial tcp 52.15.99.239:6443: connect: connection refused 
WARNING Failed to connect events watcher: Get https://hongkliu-api.qe.devcluster.openshift.com:6443/api/v1/namespaces/kube-system/events?resourceVersion=2465&watch=true: dial tcp 18.224.160.22:6443: connect: connection refused 
WARNING Failed to connect events watcher: Get https://hongkliu-api.qe.devcluster.openshift.com:6443/api/v1/namespaces/kube-system/events?resourceVersion=2465&watch=true: dial tcp 52.15.99.239:6443: connect: connection refused 
WARNING Failed to connect events watcher: Get https://hongkliu-api.qe.devcluster.openshift.com:6443/api/v1/namespaces/kube-system/events?resourceVersion=2465&watch=true: dial tcp 52.15.99.239:6443: connect: connection refused 
WARNING Failed to connect events watcher: Get https://hongkliu-api.qe.devcluster.openshift.com:6443/api/v1/namespaces/kube-system/events?resourceVersion=2465&watch=true: dial tcp 52.15.99.239:6443: connect: connection refused 
INFO Destroying the bootstrap resources...        
INFO Waiting up to 10m0s for the openshift-console route to be created... 
INFO Install complete!                            
INFO Run 'export KUBECONFIG=/home/fedora/20190111.vikas/auth/kubeconfig' to manage the cluster with 'oc', the OpenShift CLI. 
INFO The cluster is ready when 'oc login -u kubeadmin -p bbYW3-MHd9P-EwhDh-E4ijx' succeeds (wait a few minutes). 
INFO Access the OpenShift web-console here: https://console-openshift-console.apps.hongkliu.qe.devcluster.openshift.com 
INFO Login to the console with user: kubeadmin, password: bbYW3-MHd9P-EwhDh-E4ijx 

```