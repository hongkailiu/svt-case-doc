variable "region" {
  default = "us-west-2"
}

variable "cluster_name" {
  default = "hongkliu-tf"
}

variable "ami_id" {
  default = "ami-0feb1655b7868b845"
}

variable "instance_type" {
  default = "m5.xlarge"
}

variable "kubernetes_cluster_value" {
  default = "hongkliu-ocp"
}

variable "gluster_volume_size" {
  default = 1000
}

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "aws_instance" "worker" {
  ami           = "${var.ami_id}"
  instance_type = "${var.instance_type}"
  subnet_id = "subnet-4879292d"
  security_groups = [ "sg-5c5ace38" ]
  key_name = "id_rsa_perf"
  tags = {
    Name = "${var.cluster_name}-worker-${count.index + 1}"
    KubernetesCluster = "${var.kubernetes_cluster_value}"
  }
  root_block_device = {
      volume_size = 23
      volume_type = "gp2"
      delete_on_termination =  true
    }
  count = 2
}

resource "aws_instance" "infra" {
  ami           = "${var.ami_id}"
  instance_type = "${var.instance_type}"
  subnet_id = "subnet-4879292d"
  security_groups = [ "sg-5c5ace38" ]
  key_name = "id_rsa_perf"
  tags = {
    Name = "${var.cluster_name}-infra-${count.index + 1}"
    KubernetesCluster = "${var.kubernetes_cluster_value}"
  }
  root_block_device = {
      volume_size = 23
      volume_type = "gp2"
      delete_on_termination =  true
    }
  count = 1
}


resource "aws_instance" "master" {
  ami           = "${var.ami_id}"
  instance_type = "${var.instance_type}"
  subnet_id = "subnet-4879292d"
  security_groups = [ "sg-5c5ace38" ]
  key_name = "id_rsa_perf"
  tags = {
    Name = "${var.cluster_name}-master-${count.index + 1}"
    KubernetesCluster = "${var.kubernetes_cluster_value}"
  }
  root_block_device = {
    volume_size = 23
    volume_type = "gp2"
    delete_on_termination =  true
  }
  count = 1
}

resource "aws_instance" "gluster" {
  ami           = "${var.ami_id}"
  instance_type = "${var.instance_type}"
  subnet_id = "subnet-4879292d"
  security_groups = [ "sg-5c5ace38" ]
  key_name = "id_rsa_perf"
  tags = {
    Name = "${var.cluster_name}-gluster-${count.index + 1}"
    KubernetesCluster = "${var.kubernetes_cluster_value}"
  }
  root_block_device = {
    volume_size = 23
    volume_type = "gp2"
    delete_on_termination =  true
  }

  ebs_block_device = {
    device_name = /dev/sdf
    volume_size = "${var.gluster_volume_size}"
    volume_type = "gp2"
    delete_on_termination =  true
  }
  count = 0
}