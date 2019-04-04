# AWS CloudFormation - UPI - User Provided Infrastructure

It is basic tutorial how to install OpenShift 4.x on AWS User Provided Infrastructure (UPI)
Based on:
https://github.com/openshift/installer/blob/master/docs/user/aws/install_upi.md
Used templates:
https://github.com/openshift/installer/tree/master/upi/aws/cloudformation
OpenShift installer:
https://github.com/openshift/installer/releases

Copy/paste commands in this order should install OpenShift on your AWS infrastructure.

### Ignition configuration:

* Create Ignition Config files - you will need them later during the process.

```bash
./openshift-install create ignition-configs
```

* Export your cluster name (the same like in previous step)

```bash
export CLUSTER_NAME=skordas
```

* Get all CloudFormation files you need to provide base setup

Nicer and more correct way but take lots of space:

```bash
git clone https://github.com/openshift/installer.git
cp installer/upi/aws/cloudformation/*.* $PWD
```

Or cleaner - Download files you need.

```bash
wget https://raw.githubusercontent.com/openshift/installer/master/upi/aws/cloudformation/01_vpc.yaml https://raw.githubusercontent.com/openshift/installer/master/upi/aws/cloudformation/02_cluster_infra.yaml https://raw.githubusercontent.com/openshift/installer/master/upi/aws/cloudformation/03_cluster_security.yaml https://raw.githubusercontent.com/openshift/installer/master/upi/aws/cloudformation/04_cluster_bootstrap.yaml https://raw.githubusercontent.com/openshift/installer/master/upi/aws/cloudformation/05_cluster_master_nodes.yaml https://raw.githubusercontent.com/openshift/installer/master/upi/aws/cloudformation/06_cluster_worker_node.yaml
```

### Create VPC

* Create Virtual Private Cloud stack 

```bash
aws cloudformation create-stack --stack-name $CLUSTER_NAME-vpc --template-body file://01_vpc.yaml
```

Wait few minutes to provide stack

* Verify if everything is correct and get all information you need to proceed with next steps

* Verification:

```bash
aws cloudformation describe-stacks --stack-name $CLUSTER_NAME-vpc
```

It should be in CREATE_COMPLETE state.

* Get and store information to use in next steps

PrivateSubnetIds
PublicSubnetIds
VpcId

```bash
export PRIVATE_SUBNET_IDS=$(aws cloudformation describe-stacks --stack-name $CLUSTER_NAME-vpc | grep PrivateSubnetIds | cut -f 4)
export PUBLIC_SUBNET_IDS=$(aws cloudformation describe-stacks --stack-name $CLUSTER_NAME-vpc | grep PublicSubnetIds | cut -f 4)
export VPC_ID=$(aws cloudformation describe-stacks --stack-name $CLUSTER_NAME-vpc | grep VpcId | cut -f 4)
echo "PrivateSubnetIds: $PRIVATE_SUBNET_IDS" && echo "PublicSubnetIds:  $PUBLIC_SUBNET_IDS" && echo "VpcId:            $VPC_ID"
```

### Create DNS and Load Balancer stack - infra

```bash
aws cloudformation create-stack --stack-name $CLUSTER_NAME-infra --template-body file://02_cluster_infra.yaml --parameters ParameterKey=ClusterName,ParameterValue=$CLUSTER_NAME ParameterKey=HostedZoneId,ParameterValue=Z3B3KOVA3TRCWP ParameterKey=HostedZoneName,ParameterValue=qe.devcluster.openshift.com ParameterKey=PublicSubnets,ParameterValue=$PUBLIC_SUBNET_IDS ParameterKey=PrivateSubnets,ParameterValue=$PRIVATE_SUBNET_IDS ParameterKey=VpcId,ParameterValue=$VPC_ID --capabilities CAPABILITY_NAMED_IAM
```

Wait few minutes to provide stack

* Verify if everything is correct and get all information you need to proceed with next steps

* Verification:

```bash
aws cloudformation describe-stacks --stack-name $CLUSTER_NAME-infra
```

It should be in CREATE_COMPLETE state.

* Get and store information to use in next steps

ExternalApiTargetGroupArn
InternalApiTargetGroupArn
PrivateHostedZoneId
RegisterNlbIpTargetsLambda
InternalServiceTargetGroupArn

```bash
export EXTERNAL_API_TARGET_GROUP_ARN=$(aws cloudformation describe-stacks --stack-name $CLUSTER_NAME-infra | grep ExternalApiTargetGroupArn | cut -f 4)
export INTERNAL_API_TARGET_GROUP_ARN=$(aws cloudformation describe-stacks --stack-name $CLUSTER_NAME-infra | grep InternalApiTargetGroupArn | cut -f 4)
export PRIVATE_HOSTED_ZONE_ID=$(aws cloudformation describe-stacks --stack-name $CLUSTER_NAME-infra | grep PrivateHostedZoneId | cut -f 4)
export REGISTER_NLB_IP_TARGETS_LAMBDA=$(aws cloudformation describe-stacks --stack-name $CLUSTER_NAME-infra | grep RegisterNlbIpTargetsLambda | cut -f 4)
export INTERNAL_SERVICE_TARGET_GROUP_ARN=$(aws cloudformation describe-stacks --stack-name $CLUSTER_NAME-infra | grep InternalServiceTargetGroupArn | cut -f 4)
echo "ExternalApiTargetGroupArn:     $EXTERNAL_API_TARGET_GROUP_ARN" && echo "InternalApiTargetGroupArn:     $INTERNAL_API_TARGET_GROUP_ARN" && echo "PrivateHostedZoneId:           $PRIVATE_HOSTED_ZONE_ID" && echo "RegisterNlbIpTargetsLambda:    $REGISTER_NLB_IP_TARGETS_LAMBDA" && echo "InternalServiceTargetGroupArn: $INTERNAL_SERVICE_TARGET_GROUP_ARN"
```

### Create Security Group stack

```bash
aws cloudformation create-stack --stack-name $CLUSTER_NAME-sg --template-body file://03_cluster_security.yaml --parameters ParameterKey=ClusterName,ParameterValue=$CLUSTER_NAME ParameterKey=VpcId,ParameterValue=$VPC_ID ParameterKey=PrivateSubnets,ParameterValue=$PRIVATE_SUBNET_IDS --capabilities CAPABILITY_NAMED_IAM
```

* Verification:

```bash
aws cloudformation describe-stacks --stack-name $CLUSTER_NAME-sg
```

* Get and store information to use in next steps

MasterSecurityGroupId
MasterInstanceProfile
WorkerSecurityGroupId
WorkerInstanceProfile

```bash
export MASTER_SECURITY_GROUP_ID=$(aws cloudformation describe-stacks --stack-name $CLUSTER_NAME-sg | grep MasterSecurityGroupId | cut -f 4)
export MASTER_INSTANCE_PROFILE=$(aws cloudformation describe-stacks --stack-name $CLUSTER_NAME-sg | grep MasterInstanceProfile | cut -f 4)
export WORKER_SECURITY_GROUP_ID=$(aws cloudformation describe-stacks --stack-name $CLUSTER_NAME-sg | grep WorkerSecurityGroupId | cut -f 4)
export WORKER_INSTANCE_PROFILE=$(aws cloudformation describe-stacks --stack-name $CLUSTER_NAME-sg | grep WorkerInstanceProfile | cut -f 4)
echo "MasterSecurityGroupId: $MASTER_SECURITY_GROUP_ID" && echo "MasterInstanceProfile: $MASTER_INSTANCE_PROFILE" && echo "WorkerSecurityGroupId: $WORKER_SECURITY_GROUP_ID" && echo "WorkerInstanceProfile: $WORKER_INSTANCE_PROFILE"
```

### Creating Bootstrap node

* Select AMI of OS you want to use - select version and build correct to your region. 

Go to https://releases-redhat-coreos.cloud.paas.upshift.redhat.com/ 

```bash
export RHCOS_AMI=ami-026d285b42705e30e
```


* Create own bucket on AWS

```bash
aws s3 mb s3://$CLUSTER_NAME-upi
```

* Upload bootstrap ignition config

```bash
aws s3 cp bootstrap.ign s3://$CLUSTER_NAME-upi/bootstrap.ign
```

* Verification:

```bash
aws s3 ls s3://$CLUSTER_NAME-upi/ 
```

* Create Bootstrap node

```bash
aws cloudformation create-stack --stack-name $CLUSTER_NAME-boot --template-body file://04_cluster_bootstrap.yaml --parameters ParameterKey=ClusterName,ParameterValue=$CLUSTER_NAME ParameterKey=RhcosAmi,ParameterValue=$RHCOS_AMI ParameterKey=PublicSubnet,ParameterValue=$PUBLIC_SUBNET_IDS  ParameterKey=MasterSecurityGroupId,ParameterValue=$MASTER_SECURITY_GROUP_ID ParameterKey=VpcId,ParameterValue=$VPC_ID ParameterKey=BootstrapIgnitionLocation,ParameterValue=s3://$CLUSTER_NAME-upi/bootstrap.ign ParameterKey=RegisterNlbIpTargetsLambdaArn,ParameterValue="$REGISTER_NLB_IP_TARGETS_LAMBDA" ParameterKey=ExternalApiTargetGroupArn,ParameterValue="$EXTERNAL_API_TARGET_GROUP_ARN" ParameterKey=InternalApiTargetGroupArn,ParameterValue="$INTERNAL_API_TARGET_GROUP_ARN" ParameterKey=InternalServiceTargetGroupArn,ParameterValue="$INTERNAL_SERVICE_TARGET_GROUP_ARN"  --capabilities CAPABILITY_NAMED_IAM
```

* Verification:

```bash
aws cloudformation describe-stacks --stack-name $CLUSTER_NAME-boot
```

### Creating master nodes:

* Make backup copy of file:

```bash
cp 05_cluster_master_nodes.yaml 05_cluster_master_nodes_backup.yam
```

* get CertificateAuthorities from master.ign and put that value into cloudformation yaml in Parameters.CertificateAuthorities.Default

```bash
cat master.ign | jq -r '.ignition.security.tls.certificateAuthorities[].source'
vim 05_cluster_master_nodes.yaml

# Or using copy/paste one command line:
sed -i "s#data:text/plain;charset=utf-8;base64,ABC...xYz==#$(cat master.ign | jq -r '.ignition.security.tls.certificateAuthorities[].source')#g" 05_cluster_master_nodes.yaml

```

* Create master node and DNS for etcd

```bash
aws cloudformation create-stack --stack-name $CLUSTER_NAME-master --template-body file://05_cluster_master_nodes.yaml --parameters ParameterKey=ClusterName,ParameterValue=$CLUSTER_NAME ParameterKey=RhcosAmi,ParameterValue=$RHCOS_AMI ParameterKey=IgnitionLocation,ParameterValue=https://api.$CLUSTER_NAME.qe.devcluster.openshift.com:22623/config/master ParameterKey=PrivateHostedZoneId,ParameterValue=$PRIVATE_HOSTED_ZONE_ID ParameterKey=PrivateHostedZoneName,ParameterValue=$CLUSTER_NAME.qe.devcluster.openshift.com ParameterKey=Master0Subnet,ParameterValue=$PRIVATE_SUBNET_IDS ParameterKey=Master1Subnet,ParameterValue=$PRIVATE_SUBNET_IDS ParameterKey=Master2Subnet,ParameterValue=$PRIVATE_SUBNET_IDS ParameterKey=MasterSecurityGroupId,ParameterValue=$MASTER_SECURITY_GROUP_ID ParameterKey=MasterInstanceProfileName,ParameterValue="$MASTER_INSTANCE_PROFILE" ParameterKey=RegisterNlbIpTargetsLambdaArn,ParameterValue="$REGISTER_NLB_IP_TARGETS_LAMBDA" ParameterKey=ExternalApiTargetGroupArn,ParameterValue="$EXTERNAL_API_TARGET_GROUP_ARN" ParameterKey=InternalApiTargetGroupArn,ParameterValue="$INTERNAL_API_TARGET_GROUP_ARN" ParameterKey=InternalServiceTargetGroupArn,ParameterValue="$INTERNAL_SERVICE_TARGET_GROUP_ARN" --capabilities CAPABILITY_NAMED_IAM
```

* Verification:

```bash
aws cloudformation describe-stacks --stack-name $CLUSTER_NAME-master
```

### Creating worker nodes

* make backup copy of file:

```bash
cp 06_cluster_worker_node.yaml 06_cluster_worker_node_buckup.yaml
```

* get CertificateAuthorities from worker.ign and put that value into cloudformation yaml in Parameters.CertificateAuthorities.Default

```bash
cat worker.ign | jq -r '.ignition.security.tls.certificateAuthorities[].source'
vim 06_cluster_worker_node.yaml

# Or using copy/paste one command line:
sed -i "s#data:text/plain;charset=utf-8;base64,ABC...xYz==#$(cat worker.ign | jq -r '.ignition.security.tls.certificateAuthorities[].source')#g" 06_cluster_worker_node.yaml

```

* Create worker node and DNS for etcd

```bash
aws cloudformation create-stack --stack-name $CLUSTER_NAME-worker --template-body file://06_cluster_worker_node.yaml --parameters ParameterKey=ClusterName,ParameterValue=$CLUSTER_NAME ParameterKey=RhcosAmi,ParameterValue=$RHCOS_AMI ParameterKey=IgnitionLocation,ParameterValue=https://api.$CLUSTER_NAME.qe.devcluster.openshift.com:22623/config/worker ParameterKey=WorkerSubnet,ParameterValue=$PRIVATE_SUBNET_IDS ParameterKey=WorkerSecurityGroupId,ParameterValue=$WORKER_SECURITY_GROUP_ID ParameterKey=WorkerInstanceProfileName,ParameterValue="$WORKER_INSTANCE_PROFILE" --capabilities CAPABILITY_NAMED_IAM
```

* Verification:

```
aws cloudformation describe-stacks --stack-name $CLUSTER_NAME-worker
```

### Initialization of UPI

```bash
./openshift-install user-provided-infrastructure bootstrap-complete
# export kube config file:
export KUBECONFIG=$PWD/auth/kubeconfig
```

* Delete bootstarp

```bash
aws cloudformation delete-stack --stack-name $CLUSTER_NAME-boot
```

* Finish installation:

```bash
user-provided-infrastructure finish
```

* Cleanup - Deleting master machine definition

```bash
oc get machines -n openshift-machine-api

NAME                                    INSTANCE   STATE     TYPE        REGION      ZONE         AGE
skordas-tkh7l-master-0                                       m4.xlarge   us-east-2   us-east-2a   9m22s
skordas-tkh7l-master-1                                       m4.xlarge   us-east-2   us-east-2b   9m22s
skordas-tkh7l-master-2                                       m4.xlarge   us-east-2   us-east-2c   9m21s
skordas-tkh7l-worker-us-east-2a-qjcxq                        m4.large    us-east-2   us-east-2a   8m6s
skordas-tkh7l-worker-us-east-2b-nq8zs                        m4.large    us-east-2   us-east-2b   8m6s
skordas-tkh7l-worker-us-east-2c-ww6c6                        m4.large    us-east-2   us-east-2c   8m7s
$ oc delete machine -n openshift-machine-api skordas-tkh7l-master-0
machine.machine.openshift.io "skordas-tkh7l-master-0" deleted
$ oc delete machine -n openshift-machine-api skordas-tkh7l-master-1
machine.machine.openshift.io "skordas-tkh7l-master-1" deleted
$ oc delete machine -n openshift-machine-api skordas-tkh7l-master-2
machine.machine.openshift.io "skordas-tkh7l-master-2" deleted
```


### After test cleaning:

```bash
./openshift-install destroy cluster
aws cloudformation delete-stack --stack-name $CLUSTER_NAME-worker
aws cloudformation delete-stack --stack-name $CLUSTER_NAME-master
aws cloudformation delete-stack --stack-name $CLUSTER_NAME-sq
aws cloudformation delete-stack --stack-name $CLUSTER_NAME-infra
aws cloudformation delete-stack --stack-name $CLUSTER_NAME-vpr
aws s3 rm s3://$CLUSTER_NAME-upi/bootstrap.ign
aws s3 rb s3://$CLUSTER_NAME-upi
```