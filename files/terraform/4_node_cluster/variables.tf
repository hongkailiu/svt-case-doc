variable "access_key" {}
variable "secret_key" {}

variable "region" {
  default = "us-west-2"
}

variable "cluster_name" {
  default = "hongkliu-tf"
}

variable "kubernetes_cluster_value" {
  default = "hongkliu-ocp"
}

variable "ami_id" {
  default = "ami-0feb1655b7868b845"
}

variable "master_instance_count" {
  default = "1"
}

variable "master_instance_type" {
  default = "m5.xlarge"
}

variable "infra_instance_count" {
  default = "1"
}

variable "infra_instance_type" {
  default = "m5.xlarge"
}

variable "worker_instance_count" {
  default = "1"
}

variable "worker_instance_type" {
  default = "m5.xlarge"
}

variable "gluster_instance_count" {
  default = "3"
}

variable "gluster_instance_type" {
  default = "m5.xlarge"
}

variable "gluster_volume_size" {
  default = "1000"
}

variable "root_block_device_volume_size" {
  default = "23"
}
