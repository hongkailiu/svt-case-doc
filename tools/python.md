# python

## virtualenv

Set up `virtualenv` with python2 [when python 3 is the default python version](https://virtualenv.pypa.io/en/latest/reference/#virtualenv-command): Tested with Fedora 29.

```
### default python version
$ python -V
Python 2.7.15
### python2 path
$ which python2
/usr/bin/python2
### install virtualenv
$ sudo pip install virtualenv

### set up virtualenv for svt repo
$ git clone https://github.com/openshift/svt.git
$ cd svt/
$ virtualenv --python=/usr/bin/python2 svtenv
$ source svtenv/bin/activate

(svtenv) [fedora@ip-172-31-32-37 svt]$ python -V
Python 2.7.15

$ pip install boto3 python-cephlibs flask pyyaml pytimeparse

```
