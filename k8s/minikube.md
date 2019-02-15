# [minikube](https://kubernetes.io/docs/setup/minikube/)

## [installation](https://kubernetes.io/docs/tasks/tools/install-minikube/)

Test with Fedora 29 instance on EC2:

### [no VM support](https://github.com/kubernetes/minikube#linux-continuous-integration-without-vm-support)

```
### Install official docker-ce
### https://docs.docker.com/install/linux/docker-ce/fedora/
$ sudo groupadd docker
$ sudo usermod -aG docker $USER

$ sudo systemctl restart docker
### logout  and login

$ docker run hello-world

curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && chmod +x minikube && sudo cp minikube /usr/local/bin/ && rm minikube
curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x kubectl && sudo cp kubectl /usr/local/bin/ && rm kubectl

export MINIKUBE_WANTUPDATENOTIFICATION=false
export MINIKUBE_WANTREPORTERRORPROMPT=false
export MINIKUBE_HOME=$HOME
export CHANGE_MINIKUBE_NONE_USER=true
mkdir -p $HOME/.kube
mkdir -p $HOME/.minikube
touch $HOME/.kube/config

export KUBECONFIG=$HOME/.kube/config
sudo -E minikube start --vm-driver=none

# this for loop waits until kubectl can access the api server that Minikube has created
for i in {1..150}; do # timeout for 5 minutes
   kubectl get po &> /dev/null
   if [ $? -ne 1 ]; then
      break
  fi
  sleep 2
done


```

Not working with docker from fedora:

```
Feb 15 21:21:31 ip-172-31-9-245.us-west-2.compute.internal kubelet[11281]: F0215 21:21:31.383044   11281 server.go:261] failed to run Kubelet: failed to create kubelet: misconfiguration: kubelet cgroup driver: >
```

```
$ sudo chown fedora:fedora -R ~/.minikube

$ kubectl config view
apiVersion: v1
clusters:
- cluster:
    certificate-authority: /home/fedora/.minikube/ca.crt
    server: https://172.31.56.86:8443
  name: minikube
contexts:
- context:
    cluster: minikube
    user: minikube
  name: minikube
current-context: minikube
kind: Config
preferences: {}
users:
- name: minikube
  user:
    client-certificate: /home/fedora/.minikube/client.crt
    client-key: /home/fedora/.minikube/client.key


$ kubectl get namespace
NAME          STATUS   AGE
default       Active   6m
kube-public   Active   5m56s
kube-system   Active   6m

$ kubectl create -f https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/namespace_test.yaml
$ kubectl create -n ttt -f https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/pod_test.yaml
$ kubectl get pod -n ttt -o wide
NAME   READY   STATUS    RESTARTS   AGE   IP           NODE       NOMINATED NODE   READINESS GATES
web    1/1     Running   0          44s   172.17.0.4   minikube   <none>           <none>
$ curl 172.17.0.4:8080
{"version":"2.0.0","ips":["127.0.0.1","172.17.0.4"],"now":"2019-02-15T22:36:05.059501341Z"}

$ sudo -E minikube stop
```
