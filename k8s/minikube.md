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

###export MINIKUBE_WANTUPDATENOTIFICATION=false
###export MINIKUBE_WANTREPORTERRORPROMPT=false
###export MINIKUBE_HOME=$HOME
export CHANGE_MINIKUBE_NONE_USER=true
###mkdir -p $HOME/.kube
###mkdir -p $HOME/.minikube
###touch $HOME/.kube/config

###export KUBECONFIG=$HOME/.kube/config
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

### core dns is running
$ kubectl get -n kube-system pods
NAME                               READY   STATUS    RESTARTS   AGE
coredns-86c58d9df4-klgnd           1/1     Running   0          151m
coredns-86c58d9df4-s8dsx           1/1     Running   0          151m
etcd-minikube                      1/1     Running   0          151m
kube-addon-manager-minikube        1/1     Running   0          151m
kube-apiserver-minikube            1/1     Running   0          150m
kube-controller-manager-minikube   1/1     Running   0          151m
kube-proxy-plkk6                   1/1     Running   0          151m
kube-scheduler-minikube            1/1     Running   0          151m
storage-provisioner                1/1     Running   0          151m


$ kubectl create -f https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/namespace_test.yaml
$ kubectl create -n ttt -f https://raw.githubusercontent.com/hongkailiu/svt-case-doc/master/files/pod_test.yaml
$ kubectl get pod -n ttt -o wide
NAME   READY   STATUS    RESTARTS   AGE   IP           NODE       NOMINATED NODE   READINESS GATES
web    1/1     Running   0          44s   172.17.0.4   minikube   <none>           <none>
$ curl 172.17.0.4:8080
{"version":"2.0.0","ips":["127.0.0.1","172.17.0.4"],"now":"2019-02-15T22:36:05.059501341Z"}

###switch namespace https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/
$ kubectl config set-context $(kubectl config current-context) --namespace=ttt

$ cat ~/svc_test.yaml 
kind: Service
apiVersion: v1
metadata:
  name: my-service
spec:
  selector:
    app: web
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 8080

$ kubectl create -f ~/svc_test.yaml


$ kubectl get svc --all-namespaces
NAMESPACE     NAME         TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)         AGE
default       kubernetes   ClusterIP   10.96.0.1     <none>        443/TCP         178m
kube-system   kube-dns     ClusterIP   10.96.0.10    <none>        53/UDP,53/TCP   178m
ttt           my-service   ClusterIP   10.102.4.59   <none>        8080/TCP        41m

### on the host
### ClusterIP works, not the dns
$ curl 10.102.4.59:8080
{"version":"2.0.0","ips":["127.0.0.1","172.17.0.4"],"now":"2019-03-05T17:07:01.525379287Z"}
$ curl  http://my-service.ttt.svc.cluster.local:8080
curl: (6) Could not resolve host: my-service.ttt.svc.cluster.local
$ curl -k https://kubernetes.default.svc.cluster.local
curl: (6) Could not resolve host: kubernetes.default.svc.cluster.local
$ curl -k https://10.96.0.1
{
  "kind": "Status",
...

$ nslookup my-service.ttt.svc.cluster.local
Server:		172.31.0.2
Address:	172.31.0.2#53

** server can't find my-service.ttt.svc.cluster.local: NXDOMAIN


### inside a pod
$ kubectl exec web -i -t -- bash
[root@web /]# curl -k https://kubernetes.default.svc.cluster.local
{
  "kind": "Status",
...
[root@web /]# curl -k https://10.96.0.1
{
  "kind": "Status",
...

### does not return: tried both dns and ip
[root@web /]# curl  http://my-service.ttt.svc.cluster.local:8080
[root@web /]# curl -k http://10.102.4.59:8080

### seems dns works ... it is the network issue
[root@web /]# nslookup my-service.ttt.svc.cluster.local
Server:		10.96.0.10
Address:	10.96.0.10#53

Name:	my-service.ttt.svc.cluster.local
Address: 10.102.4.59

### FOUND the reason: this is a very special case.
### https://github.com/kubernetes/kubernetes/issues/19930#issuecomment-214954320
### use another pod it will work
$ kubectl run hello-minikube --image=k8s.gcr.io/echoserver:1.4
$ kubectl exec -i -t hello-minikube-7bcd54b57c-fznlw -- bash
### both work!
bcd54b57c-fznlw:/# curl my-service.ttt.svc.cluster.local:8080
bcd54b57c-fznlw:/# curl -k http://10.102.4.59:8080

$ sudo -E minikube stop
$ sudo -E minikube delete
```
