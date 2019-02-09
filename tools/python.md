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

On Fedora 29 (workstation): Only `python3` is installed.

```
$ sudo dnf install python2
$ which python
/usr/bin/python
$ ll /usr/bin/python
lrwxrwxrwx. 1 root root 7 Oct 15 11:26 /usr/bin/python -> python2

### new rule for myself: start to move to `python3`
### by default, explicitly specify python version 3 in the python command, ie, `python3`
### use `python2` only in the `p2env`
$ pip3 --version 
pip 18.0 from /usr/lib/python3.7/site-packages/pip (python 3.7)
$ pip3 install --user virtualenv
$ virtualenv --version
16.4.0
$ which virtualenv
~/.local/bin/virtualenv

$ virtualenv --python=/usr/bin/python2 p2env
$ source p2env/bin/activate
$ python -V
Python 2.7.15

```