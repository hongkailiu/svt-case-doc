# Image Stream

* [is@os.doc](https://docs.openshift.com/container-platform/3.11/architecture/core_concepts/builds_and_image_streams.html#image-streams)
* [managing_images@os.doc](https://docs.openshift.com/container-platform/3.11/dev_guide/managing_images.html)
* [OpenShift Image Streams and Templates library](https://github.com/openshift/library)

## understand cakephp-mysql-example template

[cakephp-mysql-example.yaml](../files/cakephp-mysql-example.yaml): which is generated by `oc get template -n openshift cakephp-mysql-example -o yaml > ~/cakephp-mysql-example.yaml` on OCP 4 (4.0.0-0.nightly-2019-03-06-074438).

```
$ oc new-project ttt
$ oc new-app --template=cakephp-mysql-example
$ oc get bc cakephp-mysql-example -o yaml | grep "name: php"
        name: php:7.1
### for any reason if the istags are not generated automatically on the cluster installation time, we can import them manually
### by default: this bc requires istag "php:7.1" in ns "openshift"
### and `oc import-image -n openshift php` only generates the istags "latest" and "php:7.2"
### we need to import image with more specific tag
$ oc import-image -n openshift php:7.1
### the output of this bc: is "cakephp-mysql-example:latest"

$ oc get dc mysql 
NAME    REVISION   DESIRED   CURRENT   TRIGGERED BY
mysql   1          1         1         config,image(mysql:5.7)
### it requires istag "mysql:5.7" in ns "openshift"

$ oc import-image -n openshift mysql:5.7

### when those 2 istags are generated, everything should be in the right position.
### if not, we can clean up and redeploy the template
$ oc get istag -n openshift mysql:5.7 php:7.1
NAME        IMAGE REF                                                                                                                                  UPDATED
mysql:5.7   image-registry.openshift-image-registry.svc:5000/openshift/mysql@sha256:66713598d04d7b8cc5919710ee4fe3240a5f93b9f9cbad90587f055007922e3d   About a minute ago
NAME        IMAGE REF                                                                                                                                  UPDATED
php:7.1     image-registry.openshift-image-registry.svc:5000/openshift/php@sha256:3895d8c39906fb07578ad5eb6dbdfb91471d2ebba570c67b2a1fccdf56c40c20     12 minutes ago

### everything is in order
$ oc get dc
NAME                    REVISION   DESIRED   CURRENT   TRIGGERED BY
cakephp-mysql-example   1          1         1         config,image(cakephp-mysql-example:latest)
mysql                   1          1         1         config,image(mysql:5.7)

$ oc get pod
NAME                               READY   STATUS      RESTARTS   AGE
cakephp-mysql-example-1-build      0/1     Completed   0          2m46s
cakephp-mysql-example-1-deploy     0/1     Completed   0          68s
cakephp-mysql-example-1-hook-pre   0/1     Completed   0          61s
cakephp-mysql-example-1-qfcnq      1/1     Running     0          40s
mysql-1-deploy                     0/1     Completed   0          2m46s
mysql-1-w44fx                      1/1     Running     0          2m36s

$ oc get routes.route.openshift.io 
NAME                    HOST/PORT                                                                       PATH   SERVICES                PORT    TERMINATION   WILDCARD
cakephp-mysql-example   cakephp-mysql-example-ttt.apps.walid03006074438m5.qe.devcluster.openshift.com          cakephp-mysql-example   <all>                 None


$ curl -s -o /dev/null -I -w "%{http_code}" cakephp-mysql-example-ttt.apps.walid03006074438m5.qe.devcluster.openshift.com
200

```

## 2 types of image stream

### normal image stream

It collects images by `.spec.tags`:

```
# oc get is -n openshift mysql -o yaml | yq -r .spec.tags[0] -y
annotations:
  description: Provides a MySQL 5.5 database on RHEL 7. For more information about
    using this database image, including OpenShift considerations, see https://github.com/sclorg/mysql-container/blob/master/README.md.
  iconClass: icon-mysql-database
  openshift.io/display-name: MySQL 5.5
  openshift.io/provider-display-name: Red Hat, Inc.
  tags: hidden,mysql
  version: '5.5'
from:
  kind: DockerImage
  name: registry.redhat.io/openshift3/mysql-55-rhel7:latest
generation: 2
importPolicy: {}
name: '5.5'
referencePolicy:
  type: Local

```

Then we can import the images by `oc import-image` command as above.
The image will be imported into the integrated registry and an `istag` object is generated when succeeded.

```
# oc get istag -n openshift mysql:5.7
NAME        IMAGE REF                                                                                                                                  UPDATED
mysql:5.7   image-registry.openshift-image-registry.svc:5000/openshift/mysql@sha256:66713598d04d7b8cc5919710ee4fe3240a5f93b9f9cbad90587f055007922e3d   4 hours ago

### to show what is the original image via "istag"
# oc get istag -n openshift mysql:5.7 -o yaml | yq -r .tag.from.name
registry.redhat.io/rhscl/mysql-57-rhel7:latest

### to show what is the original image via "is"
# oc get is -n openshift mysql -o yaml | yq -r .status.tags[0] -y
items:
- created: '2019-03-08T13:17:51'
  dockerImageReference: registry.redhat.io/openshift3/mysql-55-rhel7@sha256:3771bc829263c621f2fe79aca2909eca474c2b1f43133690ca4d3c28473128b9
  generation: 2
  image: sha256:3771bc829263c621f2fe79aca2909eca474c2b1f43133690ca4d3c28473128b9
tag: '5.5'

```

### image stream as output of bc

```
# oc get bc cakephp-mysql-example -o yaml | yq .spec.output -y
to:
  kind: ImageStreamTag
  name: cakephp-mysql-example:latest

# oc get is cakephp-mysql-example -o yaml
apiVersion: image.openshift.io/v1
kind: ImageStream
metadata:
  annotations:
    description: Keeps track of changes in the application image
    openshift.io/generated-by: OpenShiftNewApp
  creationTimestamp: 2019-03-08T13:27:31Z
  generation: 1
  labels:
    app: cakephp-mysql-example
    template: cakephp-mysql-example
  name: cakephp-mysql-example
  namespace: ttt
  resourceVersion: "23748"
  selfLink: /apis/image.openshift.io/v1/namespaces/ttt/imagestreams/cakephp-mysql-example
  uid: ecef27a2-41a5-11e9-aa00-0a580a82001c
spec:
  lookupPolicy:
    local: false
status:
  dockerImageRepository: image-registry.openshift-image-registry.svc:5000/ttt/cakephp-mysql-example
  tags:
  - items:
    - created: 2019-03-08T13:29:25Z
      dockerImageReference: image-registry.openshift-image-registry.svc:5000/ttt/cakephp-mysql-example@sha256:4a5ac3d3f868530ea4ae3cb63feadcbb2ca325ee6b85cd6670f3afcdd66c00f0
      generation: 1
      image: sha256:4a5ac3d3f868530ea4ae3cb63feadcbb2ca325ee6b85cd6670f3afcdd66c00f0
    tag: latest

```

There is no "spec.tags" defined in the above `is` while the `status.tags` shows the referred image is generated in the registry.
Because this `is` is not a normal one, we never need to run `oc import-image` on this `is`.
The `istag` `cakephp-mysql-example:latest` is generated already when the build (triggered by the `bc`) runs successfully.

```
# oc get istag
NAME                           IMAGE REF                                                                                                                                            UPDATED
cakephp-mysql-example:latest   image-registry.openshift-image-registry.svc:5000/ttt/cakephp-mysql-example@sha256:4a5ac3d3f868530ea4ae3cb63feadcbb2ca325ee6b85cd6670f3afcdd66c00f0   5 hours ago

```

As expected, no tag is defined in the `istag` cakephp-mysql-example:latest:

```
# oc get istag cakephp-mysql-example:latest -o yaml | yq .tag
null

```

So summarize:

* the `bc` cakephp-mysql-example is trigger by (php) ImageChange, ConfigChange, and source code change on GitHub. It also outputs `istag` cakephp-mysql-example:latest.

```
# oc get bc cakephp-mysql-example -o yaml | yq .spec.triggers -y
- imageChange:
    lastTriggeredImageID: image-registry.openshift-image-registry.svc:5000/openshift/php@sha256:3895d8c39906fb07578ad5eb6dbdfb91471d2ebba570c67b2a1fccdf56c40c20
  type: ImageChange
- type: ConfigChange
- github:
    secret: v7qDbiuIYhFIGiavgILL0gWsYJlCV6bS7CP2lKwi
  type: GitHub

```
* The `dc` cakephp-mysql-example is triggered by ConfigChange and (cakephp-mysql-example:latest) ImageChange. Similarly, the dc `mysql` is triggered by ConfigChange and (mysql:5.7) ImageChange.

```
# oc get dc
NAME                    REVISION   DESIRED   CURRENT   TRIGGERED BY
cakephp-mysql-example   1          1         1         config,image(cakephp-mysql-example:latest)
mysql                   1          1         1         config,image(mysql:5.7)
```

