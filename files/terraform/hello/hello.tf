variable "cluster_name" {
  default = "hongkliu-tf"
}

variable "ami_id" {
  default = "ami-0feb1655b7868b845"
}

variable "instance_type" {
  default = "m5.xlarge"
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
    "Name" = "${var.cluster_name}-worker-${count.index + 1}"
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
    "Name" = "${var.cluster_name}-infra-${count.index + 1}"
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
    "Name" = "${var.cluster_name}-master-${count.index + 1}"
  }
  count = 1
}
