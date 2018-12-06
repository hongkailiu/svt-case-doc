# Security

## Doc

* [linux kernel security](https://www.linux.com/learn/overview-linux-kernel-security-features)
* [selinux](selinux.md), [linux namespace](https://en.wikipedia.org/wiki/Linux_namespaces), and [cgroup](https://en.wikipedia.org/wiki/Cgroups)
* [Dan Walsh's Blog](http://danwalsh.livejournal.com/), [security@docker](https://docs.docker.com/engine/security/security/), [security@container](https://opensource.com/business/14/7/docker-security-selinux)
* [sc@k8s](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)
* [secure-k8s](https://blog.openshift.com/securing-kubernetes/)
* oc: [authentication](https://docs.openshift.com/container-platform/3.6/architecture/additional_concepts/authentication.html) and [authorization](https://docs.openshift.com/container-platform/3.6/architecture/additional_concepts/authorization.html), [configure-sa](https://docs.openshift.com/container-platform/3.6/admin_guide/service_accounts.html), [manage-scc](https://docs.openshift.com/container-platform/3.6/admin_guide/manage_scc.html), [manage-policy](https://docs.openshift.com/container-platform/3.6/admin_guide/manage_authorization_policy.html)

In order to solve the tasks listed below, read doc:
* [sa&scc-blog](https://blog.openshift.com/understanding-service-accounts-sccs/)


## Policy
A policy defines what a [user/group](https://docs.openshift.com/container-platform/3.6/architecture/additional_concepts/authentication.html#users-and-groups) can do.

* A policy defines rules, roles, bindings. Only one policy, _default_, is defined out of box. [View it](https://docs.openshift.com/container-platform/3.6/admin_guide/manage_authorization_policy.html#viewing-roles-and-bindings).
* Polocy level: [cluster and local](https://docs.openshift.com/container-platform/3.6/architecture/additional_concepts/authorization.html#cluster-policy-and-local-policy). Local actually means project.

[Determine what I can do](https://docs.openshift.com/container-platform/3.6/architecture/additional_concepts/authorization.html#authorization-determining-what-you-can-do-as-an-authenticated-user):

```sh
# oc policy can-i --list
```

## [SCC](https://docs.openshift.org/latest/architecture/additional_concepts/authorization.html#security-context-constraints)

SCC defines what a _pod_ can do. Those 7 SCCs come out of the box (_restricted_ is default):

```sh
# oc get scc
NAME               PRIV      CAPS      SELINUX     RUNASUSER          FSGROUP     SUPGROUP    PRIORITY   READONLYROOTFS   VOLUMES
anyuid             false     []        MustRunAs   RunAsAny           RunAsAny    RunAsAny    10         false            [configMap downwardAPI emptyDir persistentVolumeClaim projected secret]
hostaccess         false     []        MustRunAs   MustRunAsRange     MustRunAs   RunAsAny    <none>     false            [configMap downwardAPI emptyDir hostPath persistentVolumeClaim projected secret]
hostmount-anyuid   false     []        MustRunAs   RunAsAny           RunAsAny    RunAsAny    <none>     false            [configMap downwardAPI emptyDir hostPath nfs persistentVolumeClaim projected secret]
hostnetwork        false     []        MustRunAs   MustRunAsRange     MustRunAs   MustRunAs   <none>     false            [configMap downwardAPI emptyDir persistentVolumeClaim projected secret]
nonroot            false     []        MustRunAs   MustRunAsNonRoot   RunAsAny    RunAsAny    <none>     false            [configMap downwardAPI emptyDir persistentVolumeClaim projected secret]
privileged         true      [*]       RunAsAny    RunAsAny           RunAsAny    RunAsAny    <none>     false            [*]
restricted         false     []        MustRunAs   MustRunAsRange     MustRunAs   RunAsAny    <none>     false            [configMap downwardAPI emptyDir persistentVolumeClaim projected secret]
```

SCC can define [Linux capabilities](https://docs.docker.com/engine/reference/run/#runtime-privilege-and-linux-capabilities) that a container can use.

## [SA](https://docs.openshift.org/latest/dev_guide/service_accounts.html)

SA gives a way to impersonate. Those 3 SCCs come out of the box: builder/deployer to run build/deploy pods, default to run other pods, or do any object operation.

```sh
# oc get sa -n default
NAME       SECRETS   AGE
builder    2         14h
default    3         14h
deployer   2         14h
registry   4         14h
router     2         14h
```

## User in the container

Use [pvc_ebs.yaml](../files/pvc_ebs.yaml) and [rs_bbb.yaml](../files/rs_test.yaml).

```sh
# #Do NOT make redhat as admin of cluster
# oc login -u redhat -p <secret>
# oc create -f pvc_ebs.yaml
# oc get pvc
NAME      STATUS    VOLUME                                     CAPACITY   ACCESSMODES   STORAGECLASS   AGE
pvc-ebs   Bound     pvc-06e77f8a-82af-11e7-aeaf-02c36d111da6   1Gi        RWO           gp2            11m
# oc new-project bbb
# create -f rs_bbb.yaml
# oc get pod
NAME               READY     STATUS    RESTARTS   AGE
frontend-1-6cf7h   1/1       Running   0          11m
# oc exec frontend-1-6cf7h -- id
uid=1000080000 gid=0(root) groups=0(root),1000080000
# oc exec frontend-1-6cf7h -- whoami
whoami: cannot find name for user ID 1000080000
command terminated with exit code 1
# oc exec frontend-1-6cf7h -- touch /myapp/aaa.txt
touch: cannot touch '/myapp/aaa.txt': Permission denied
command terminated with exit code 1
# oc exec frontend-1-6cf7h -- ls -Z /myapp
drwxr-xr-x. 1000 1000 system_u:object_r:svirt_sandbox_file_t:s0:c4,c9 svt
-rw-r--r--. root root system_u:object_r:svirt_sandbox_file_t:s0:c4,c9 svt-0.0.1-Linux-x86_64.tar.gz
# oc exec frontend-1-6cf7h -- touch /mydata/aaa.txt
# oc exec frontend-1-6cf7h -- ls -Z /mydata/
-rw-r--r--. 1000080000 1000080000 system_u:object_r:svirt_sandbox_file_t:s0:c4,c9 aaa.txt
drwxrwS---. root       1000080000 system_u:object_r:svirt_sandbox_file_t:s0:c4,c9 lost+found
```

Observation:

* _permission denied_ on <code>/myapp</code>: This is different from <code>docker run</code> command.
* We can write on the mounted volume. This is cool. At least we get a folder we can write.

As pointed out by [Graham Dumpleton](http://blog.dscpl.com.au/2015/12/random-user-ids-when-running-docker.html), the user in docker container is a random UID, not root.


## Task A: Why cannot Jenkens run?
Use [pod_jenkins.yaml](../files/pod_jenkins.yaml)

```sh
# oc create -f pod_jenkins.yaml
# oc logs web
touch: cannot touch '/var/jenkins_home/copy_reference_file.log': Permission denied
Can not write to /var/jenkins_home/copy_reference_file.log. Wrong volume permissions?
```

Not we can explain why it did not work. Jenkins cannot write file on <code>jenkins_home</code>. Let us use volume to fix this problem:

Use [pod_jenkins_volume.yaml](../files/pod_jenkins_volume.yaml)

```sh
# oc create -f pod_jenkins_volume.yaml
# oc get pod
NAME      READY     STATUS    RESTARTS   AGE
web       1/1       Running   0          8m
```

## Task B: Why cannot we deploy Nginx pod?
Use [pod_nginx.yaml](../files/pod_nginx.yaml)

```sh
# oc create -f pod_nginx.yaml
# oc get pod
NAME      READY     STATUS             RESTARTS   AGE
web       0/1       CrashLoopBackOff   6          9m
# oc logs web
2017/08/16 19:05:29 [warn] 1#1: the "user" directive makes sense only if the master process runs with super-user privileges, ignored in /etc/nginx/nginx.conf:2
nginx: [warn] the "user" directive makes sense only if the master process runs with super-user privileges, ignored in /etc/nginx/nginx.conf:2
2017/08/16 19:05:29 [emerg] 1#1: mkdir() "/var/cache/nginx/client_temp" failed (13: Permission denied)
nginx: [emerg] mkdir() "/var/cache/nginx/client_temp" failed (13: Permission denied)
```

Same here: It seems that nginx tries to create a folder <code>/var/cache/nginx/client_temp</code> where Permission IS denied.
The solution is the same. Let attach a volume:

Use [pod_nginx_volume.yaml](../files/pod_nginx_volume.yaml)

```sh
# oc create -f pod_nginx_volume.yaml
# oc get pod
NAME      READY     STATUS             RESTARTS   AGE
web       0/1       CrashLoopBackOff   6          9m
# oc logs web
2017/08/16 20:13:02 [warn] 1#1: the "user" directive makes sense only if the master process runs with super-user privileges, ignored in /etc/nginx/nginx.conf:2
nginx: [warn] the "user" directive makes sense only if the master process runs with super-user privileges, ignored in /etc/nginx/nginx.conf:2
2017/08/16 20:13:02 [emerg] 1#1: bind() to 0.0.0.0:80 failed (13: Permission denied)
nginx: [emerg] bind() to 0.0.0.0:80 failed (13: Permission denied)
```

We need 80 port, which means root access?

Use [pod_nginx_volume_privileged.yaml](../files/pod_nginx_volume_privileged.yaml)

```sh
# oc create -f pod_nginx_volume_privileged.yaml
Error from server (Forbidden): error when creating "pod_nginx.yaml": pods "web" is forbidden: unable to validate against any security context constraint: [provider restricted: .spec.containers[0].securityContext.privileged: Invalid value: true: Privileged containers are not allowed]
```

Two options to workaround this:

1. Get an nginx running as non-root user, not using root access, to be more precise. Preferred by OC, may not by users. Run nginx with 8080 port?
2. Give root to pod where nginux is running. You need know to what you are doing.

Grand permission via <code>scc</code>

Use [scc_aaa.yaml](../files/scc_aaa.yaml)

```sh
# only cluster-admin can manage scc
# oc config use-context default/ec2-54-244-1-118-us-west-2-compute-amazonaws-com:8443/system:admin
# oc create -f scc_aaa.yaml
# oc config use-context bbb/ip-172-31-37-36-us-west-2-compute-internal:8443/redhat
# oc create -f pod_nginx_volume_privileged.yaml
# oc get pod -o wide
NAME      READY     STATUS    RESTARTS   AGE       IP            NODE
web       1/1       Running   0          1m        172.20.0.23   ip-172-31-37-36.us-west-2.compute.internal
# curl -s -o /dev/null -w "%{http_code}" 172.20.0.23
200

```

TODO: Can we do better than <code>privileged: true</code>?

## Learning round2: 20181205

### [User](https://docs.openshift.com/container-platform/3.11/architecture/core_concepts/projects_and_users.html#users):

* regular users
* system users: created by the system, `system:admin`
* service accounts: `oc get sa -n <namespace>`. By default, 3 SAs (`builder`, `default`, and `deployer`) are created 
    when a namespace is created.
    
Relevant resources:

```bash
# oc api-resources | grep -E "user|identit"
groups                                               user.openshift.io              false        Group
identities                                           user.openshift.io              false        Identity
useridentitymappings                                 user.openshift.io              false        UserIdentityMapping
users                                                user.openshift.io              false        User

```

### [Identity provider](https://docs.openshift.com/container-platform/3.11/install_config/configuring_authentication.html#identity-providers_parameters)

At installation, [var `openshift_master_identity_providers` in the inventory](https://docs.openshift.com/container-platform/3.11/install/configuring_inventory_file.html#configuring-cluster-variables),
eg,

```bash
openshift_master_identity_providers=[{'name': 'allow_all', 'login': 'true', 'challenge': 'true', 'kind': 'AllowAllPasswordIdentityProvider'}]
```

Then the above var becomes

```bash
# grep "identityProviders" /etc/origin/master/master-config.yaml  -A7
  identityProviders:
  - challenge: true
    login: true
    mappingMethod: claim
    name: allow_all
    provider:
      apiVersion: v1
      kind: AllowAllPasswordIdentityProvider

```

### Group

A set of users.

### authorization

[Authorization](https://docs.openshift.com/container-platform/3.11/architecture/additional_concepts/authorization.html#overview)
 is managed using:
 
* Rules: Sets of permitted verbs (get, list, create, update, delete, deletecollection or watch) on a set of objects (containers, pods, users, templates, etc).
 
* Roles: Collections of rules. Users and groups can be associated with, or bound to, multiple roles at the same time.
 
* Bindings: Associations between users and/or groups with a role.

[Viewing cluster/local roles and rolebinding](https://docs.openshift.com/container-platform/3.11/admin_guide/manage_rbac.html#viewing-cluster-roles)

```bash
### every unusual oc command because the object such as 'clusterrole.rbac' is not even a resource
### role-based access control (RBAC)
$ oc describe clusterrole.rbac
$ oc describe clusterrolebinding.rbac
$ oc describe role.rbac -n <project_name>
$ oc describe rolebinding.rbac -n <project_name>

```

[Managing role bindings](https://docs.openshift.com/container-platform/3.11/admin_guide/manage_rbac.html#managing-role-bindings)

`$ oc adm policy ...` eg,

```bash
### add cluster-role 'cluster-admin' to user 'redhat'
# oc adm policy add-cluster-role-to-user cluster-admin redhat

```

See the meeting of `policy` above. I believe the term `policy` is replaced by `rbac`.