# Extended-Test@Origin

## Doc

* [extended-test@oc-origin](https://github.com/openshift/origin/tree/master/test/extended)
* [e2e-test@k8s](https://github.com/kubernetes/community/blob/master/contributors/devel/e2e-tests.md)
* [ginkgo](ginkgo.md)
* report: a concept in
    [extended test](https://github.com/openshift/origin/blob/master/test/extended/util/test.go#L80)
    which is inherited from
    [k8s-e2c test](https://github.com/hongkailiu/kubernetes/blob/master/test/e2e/framework/util.go#L4491)
    which probably (need supporting proof) uses [ginkgo junit feature](https://onsi.github.io/ginkgo/#generating-junit-xml-output).
* label: a general rule about the character, eg, _slow_ and _flaky_,
    or the category, eg, _Conformance_, or the targeting component, eg,
    _router_, of the test. See [this test](https://github.com/openshift/origin/blob/master/test/extended/router/metrics.go#L25) for example.

## Build/Run test

There are several ways to run extended tests. Note that cluster-loader is only one of the extended tests. Our beloved cluster-loader has a [page](https://docs.openshift.com/container-platform/3.7/scaling_performance/using_cluster_loader.html) in openshift-doc.

If you want to use extended test as a tool, instead of doing development/fixing bugs of the tool, use the released PRM is the best way. Otherwise, run it from the local build or src as described below.

### Run from released rpm
on our master, the binary for running extended tests is already installed. It came with `atomic-openshift-tests` from `aos` repo:

```sh
# yum info atomic-openshift-tests
Loaded plugins: amazon-id, rhui-lb, search-disabled-repos
Installed Packages
Name        : atomic-openshift-tests
Arch        : x86_64
Version     : 3.9.0
Release     : 0.22.0.git.0.d4658fb.el7
Size        : 182 M
Repo        : installed
From repo   : aos
Summary     : Origin Test Suite
URL         : https://github.com/openshift/origin
License     : ASL 2.0
Description : Origin Test Suite

```

[Here](https://github.com/openshift/svt/blob/master/openshift_scalability/nodeVertical.sh#L25) shows how we run cluster-loader on master:

```sh
### scp admin.kubeconfig from master node
$ scp -i ~/.ssh/id_rsa_perf root@ec2-54-191-255-61.us-west-2.compute.amazonaws.com:/etc/origin/master/admin.kubeconfig /tmp/
# KUBECONFIG=/path/to/admin.kubeconfig /usr/libexec/atomic-openshift/extended.test --ginkgo.focus="Load cluster" --viper-config=$MY_CONFIG
```

### Run from local build
Get dependencies:

```sh
$ go get github.com/onsi/ginkgo/ginkgo
$ go get github.com/onsi/gomega/...
```

Build the binary:

```sh
$ make build WHAT=test/extended/extended.test
$ ll _output/local/bin/linux/amd64/extended.test
-rwxrwxr-x. 1 fedora fedora 180904704 Jan 23 01:53 _output/local/bin/linux/amd64/extended.test
```

Run cluster-loader: This requires `oc` command in `${PATH}`.

```sh
# KUBECONFIG=/tmp/admin.kubeconfig  _output/local/bin/linux/amd64/extended.test --ginkgo.focus="Load cluster" --viper-config=$MY_CONFIG
```

### Run from src: test/extended/core.sh: NOT WORKING YET


Run cluster-loader: No need to install `oc` command because it will build it on the fly.

```sh
### --viper-config not working yet
$ FOCUS='Load cluster' KUBECONFIG=/tmp/admin.kubeconfig TEST_ONLY=true test/extended/core.sh --viper-config=$MY_CONFIG

### --viper-config not working yet even with the following var:
TEST_EXTENDED_ARGS="--viper-config=config/golang/pyconfigStatefulSet"
```


## Cluster loader

### Config file

[Here](https://github.com/openshift/origin/blob/master/test/extended/testdata/cluster/master-vert.yaml) is an example.

On master

```sh
# cd svt/openshift_scalability
# cp /etc/origin/master/admin.kubeconfig /tmp/
# KUBECONFIG=/tmp/admin.kubeconfig _output/local/bin/linux/amd64/extended.test --ginkgo.focus="Load cluster" --viper-config=config/golang/pyconfigStatefulSet
```

Some wholes for us when transforming python config files to golang:

* In the above command, the actual config file is `config/golang/pyconfigStatefulSet.yaml`. However, no extension `.yaml` is allowed in the args of the command. This is actually in the [doc](https://docs.openshift.com/container-platform/3.7/scaling_performance/using_cluster_loader.html). I spent 3 hours figuring this out. Shame on myself.

* (Update on Feb 26 2018: This is not true any more. The logic of handling templates changed) If templates are used in the config files, we need to be sure `oc create -f <template.file>` works. The go version cluster-loader uses that command to create template and then use the template name to create items in the template. The python version uses `oc proess -f <template.file> > tmp.file && oc create -f tmp.file`. The `process` command tolerates more.
  - use `kind` instead of `Kind`: lowercase k.
  - template name: no upper case allowed.


## Update on 20190723

```
$ oc version
oc v3.11.0+8de5c34
kubernetes v1.10.0+d4cacc0
features: Basic-Auth GSSAPI Kerberos SPNEGO

Server https://api.sj-071819-1.perf-testing.devcluster.openshift.com:6443
kubernetes v1.13.4+6569b4f

$ sudo dnf install krb5-devel
$ make build-extended-test

$ pwd
/home/hongkliu/Downloads/e2e.sjug
[hongkliu@MiWiFi-R1CM-srv e2e.sjug]$ cat nodeVertical.yaml 
provider: local
ClusterLoader:
  cleanup: true
  projects:
    - num: 1
      basename: clusterproject
      tuning: default
      ifexists: delete
      pods:
        - num: 150
          image: gcr.io/google_containers/pause-amd64:3.0
          basename: pausepods
          file: pod-pause.json
  tuningsets:
    - name: default
      pods:
        stepping:
          stepsize: 50
          pause: 60
        ratelimit:
          delay: 0
[hongkliu@MiWiFi-R1CM-srv e2e.sjug]$ cat pod-pause.json 
{
  "kind": "Pod",
  "apiVersion": "v1",
  "metadata": {
    "name": "pause-amd64",
    "creationTimestamp": null,
    "labels": {
      "name": "pause-amd64"
    }
  },
  "spec": {
    "containers": [
      {
        "name": "pause-amd64",
        "image": "gcr.io/google_containers/pause-amd64:3.0",
        "ports": [
          {
            "containerPort": 8080,
            "protocol": "TCP"
          }
        ],
        "terminationMessagePath": "/dev/termination-log",
        "imagePullPolicy": "IfNotPresent",
        "capabilities": {},
        "securityContext": {
          "capabilities": {},
          "privileged": false
        }
      }
    ],
    "restartPolicy": "Always",
    "dnsPolicy": "ClusterFirst",
    "serviceAccount": ""
  },
  "status": {}
}



$ KUBECONFIG=/home/hongkliu/.kube/config VIPERCONFIG=/home/hongkliu/Downloads/e2e.sjug/nodeVertical.yaml ./_output/local/bin/linux/amd64/openshift-tests run-test "[Feature:Performance][Serial][Slow] Load cluster should load the cluster [Suite:openshift]"


```
