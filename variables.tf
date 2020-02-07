variable "project" {
  description = " Google Cloud Platform - Project "
  type        = string
  default     = "devopsbar20"
}

variable "region" {
  description = " Google Cloud Platform - Region "
  type        = string
  default     = "us-west1"
}

variable "machine_type" {
  description = " Machine type "
  type        = string
  default     = "n1-standard-1"
}

variable "zone" {
  description = " Zone "
  type        = string
  default     = "us-west1-a"
}

variable "image" {
  description = " Image "
  type        = string
  default     = "centos-7"
}

variable "path" {
  description = "Ansible playbook path"
  type        = string
  default     = "/terraform/terraform-k8s-gce-hdfs/ansible_playbook"
}

variable "passwd" {
  description = "Password"
  type = string
  default = "ansible123"
}
