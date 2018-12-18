

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "aws_instance" "worker" {
  ami           = "${var.ami_id}"
  instance_type = "${var.worker_instance_type}"
  subnet_id = "subnet-4879292d"
  security_groups = [ "sg-5c5ace38" ]
  key_name = "id_rsa_perf"
  tags = {
    Name = "${var.cluster_name}-worker-${count.index + 1}"
    KubernetesCluster = "${var.kubernetes_cluster_value}"
  }
  root_block_device = {
      volume_size = "${var.root_block_device_volume_size}"
      volume_type = "gp2"
      delete_on_termination =  true
    }
  count = "${var.worker_instance_count}"
}

resource "aws_instance" "infra" {
  ami           = "${var.ami_id}"
  instance_type = "${var.infra_instance_type}"
  subnet_id = "subnet-4879292d"
  security_groups = [ "sg-5c5ace38" ]
  key_name = "id_rsa_perf"
  tags = {
    Name = "${var.cluster_name}-infra-${count.index + 1}"
    KubernetesCluster = "${var.kubernetes_cluster_value}"
  }
  root_block_device = {
      volume_size = "${var.root_block_device_volume_size}"
      volume_type = "gp2"
      delete_on_termination =  true
    }
  count = "${var.infra_instance_count}"
}


resource "aws_instance" "master" {
  ami           = "${var.ami_id}"
  instance_type = "${var.master_instance_type}"
  subnet_id = "subnet-4879292d"
  security_groups = [ "sg-5c5ace38" ]
  key_name = "id_rsa_perf"
  tags = {
    Name = "${var.cluster_name}-master-${count.index + 1}"
    KubernetesCluster = "${var.kubernetes_cluster_value}"
  }
  root_block_device = {
    volume_size = "${var.root_block_device_volume_size}"
    volume_type = "gp2"
    delete_on_termination =  true
  }
  count = "${var.master_instance_count}"
}

resource "aws_instance" "gluster" {
  ami           = "${var.ami_id}"
  instance_type = "${var.gluster_instance_type}"
  subnet_id = "subnet-4879292d"
  security_groups = [ "sg-5c5ace38" ]
  key_name = "id_rsa_perf"
  tags = {
    Name = "${var.cluster_name}-gluster-${count.index + 1}"
    KubernetesCluster = "${var.kubernetes_cluster_value}"
  }
  root_block_device = {
    volume_size = "${var.root_block_device_volume_size}"
    volume_type = "gp2"
    delete_on_termination =  true
  }

  ebs_block_device = {
    device_name = "/dev/sdf"
    volume_size = "${var.gluster_volume_size}"
    volume_type = "gp2"
    delete_on_termination =  true
  }
  count = "${var.gluster_instance_count}"
}