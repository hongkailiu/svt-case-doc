# Jenkins Job Builder

## Doc

* [jjb@openstack](https://docs.openstack.org/infra/jenkins-job-builder/): Yes, JJB is from Red Hat.
* [jjb@python](https://pypi.python.org/pypi/jenkins-job-builder/)
* [jjb@youtube](https://www.youtube.com/watch?v=SoP05dLe5kA): good video to start with jjb.


## Test it on localhost

Install:

```sh
[fedora@ip-172-31-55-221 jjb]$ virtualenv jjbenv
$ source jjbenv/bin/activate
$ pip install jenkins-job-builder
$ pip show jenkins-job-builder
Name: jenkins-job-builder
Version: 2.0.3
...
$ jenkins-jobs --version
Jenkins Job Builder version: 2.0.3

```

Configure:

```sh
### Get API token from Jenkins UI
### https://jenkins-ttt.apps.0327-nbn.qe.rhcloud.com/me/configure
### Or use the password directly
$ sudo mkdir /etc/jenkins_jobs/
$ sudo vi /etc/jenkins_jobs/jenkins_jobs.ini
[jenkins]
user=admin
password=password
url=https://jenkins-ttt.apps.0327-nbn.qe.rhcloud.com/
query_plugins_info=False
```

Create job:

```sh
$ mkdir jobs
$ vi jobs/test.yaml
- job:
    name: test_job
    description: 'job description'
    project-type: freestyle
    builders:
      - shell: 'ls'

### Need PYTHONHTTPSVERIFY=0 since self-signed cerificate of Jenkins
### ref. https://ghaisachin.wordpress.com/2017/02/11/jenkins-job-test-command-fails-with-certificate-verify-failed-_ssl-c590/
$ PYTHONHTTPSVERIFY=0 jenkins-jobs --flush-cache update --delete-old jobs
### Then verify on the ui and the job should be there.
```

## Test via docker

```sh
$ docker run -it --rm docker.io/hongkailiu/jjb:2.0.3 bash
root@6dc065d41347:/usr/src/app# jenkins-jobs --version
Jenkins Job Builder version: 2.0.3
```