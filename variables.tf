variable "project" {}
variable "region" {}
variable "machine_type" {}
variable "zone" {}
variable "image" {}
variable "ansible_path" {}
variable "passwd" {}
variable "k8s_master_instance_name" {}
variable "k8s_master_private_ip" {}
variable "gce_ssh_user" {}
variable "gce_ssh_pub_key_file" {}
variable "k8s_worker_instance_name" {
  type = list(string)
}
variable "k8s_worker_private_ip" {
  type = list(string)
}

