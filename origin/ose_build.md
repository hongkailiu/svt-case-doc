# OSE build

## Does my current pkg contain the fix of the bz? OCP4+

Thanks to Xingxing for the commands.

[1684547#c11](https://bugzilla.redhat.com/show_bug.cgi?id=1684547#c11) says that the fixing PRs are [origin/pull/22322](https://github.com/openshift/origin/pull/22322) and
[installer/pull/1421](https://github.com/openshift/installer/pull/1421).

Component mapping in OCP:

| image          | repo in payload | repo in upstream |
|----------------|-----------------|------------------|
| hyperkube      | ose             | origin           |
| installer      | installer       |                  |
| docker-builder | builder         |                  |

The latest nightly build: `4.0.0-0.nightly-2019-03-19-004004`. Check the commits in the payload.

* Check `ose` repo:

```
# BUILD_TAG=4.0.0-0.nightly-2019-03-19-004004
# IMAGE_NAME=hyperkube
### oc uses docker auth file by default
# oc adm release info -h | grep docker
  -a, --registry-config='': Path to your registry credentials (defaults to ~/.docker/config.json)

# oc adm release info --commits registry.svc.ci.openshift.org/ocp/release:${BUILD_TAG} | grep "${IMAGE_NAME}"
  hyperkube                                     https://github.com/openshift/ose                                           bfd0e7ce8aa0777eb7d8022bee8eb831c08ecb28

# COMMIT_HASH=bfd0e7ce8aa0777eb7d8022bee8eb831c08ecb28
# PR_NUMBER=#22322
# git clone https://github.com/openshift/ose
# cd ose/
# git log --oneline "${COMMIT_HASH}" | grep "${PR_NUMBER}"

```
The above command returned nothing: the PR is NOT included in the payload.

* Check `installer` repo

```
# IMAGE_NAME=installer
# oc adm release info --commits registry.svc.ci.openshift.org/ocp/release:${BUILD_TAG} | grep "${IMAGE_NAME}"
  installer                                     https://github.com/openshift/installer                                     af56e2db2e2601156a1ebe56269c7deb67f3c725

# COMMIT_HASH=af56e2db2e2601156a1ebe56269c7deb67f3c725
# PR_NUMBER=#1421
# cd
# git clone https://github.com/openshift/installer
# cd installer/
# git log --oneline "${COMMIT_HASH}" | grep "${PR_NUMBER}"
660f2bbf7 Merge pull request #1421 from sttts/sttts-readyz
9dd0a770c Merge pull request #1421 from cpanato/GH-1367

```

On [installer/pull/1421](https://github.com/openshift/installer/pull/1421), we find that _openshift-merge-robot merged commit 660f2bb into openshift:master  4 days ago_. The hash `660f2bb` matches the one above `660f2bbf7`.

The PR is included in the payload.

Combining both together, we cannot use the payload `4.0.0-0.nightly-2019-03-19-004004` to verify [1684547](https://bugzilla.redhat.com/show_bug.cgi?id=1684547).

## Does my current pkg contain the fix of the bz?

Before OCP 4.

For example, we have [bz 1537236](https://bugzilla.redhat.com/show_bug.cgi?id=1537236)
where the fix is [origin/pull/18544](https://github.com/openshift/origin/pull/18544).

I am using this pkg:

```sh
# yum list installed | grep openshift
atomic-openshift.x86_64         3.9.7-1.git.0.e1a30c3.el7
```

How can we know whether or not the fix/pr is included in the pkg?

From the above pr UI, we know its commit is `15c1c88b6bef9a437fed960822f203f0620b9074`.

```sh
# go get github.com/openshift/ose
# cd ~/go/src/github.com/openshift/ose/

# git tag --contains 15c1c88b6bef9a437fed960822f203f0620b9074
...
v3.9.7-1
...

# git rev-list -n 1  v3.9.7-1
e1a30c3f321a9c6809f53bd4467d6442e92522c4
```

_So in this particular case, the answer is YES (the pkg contains the pr/fix)._

Understand the version name of the pkg: 3.9.7-1.git.0.e1a30c3.el7

* 3.9.7-1: git tag
* git: constant?
* 0: #build?
* e1a30c3: git commit (first 7 digits)
* el7: os version?

? above means I am not sure.
