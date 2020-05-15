variable "project" {}
variable "region" {}
variable "machine_type" {}
variable "zone" {}
variable "image" {}
variable "k8s_worker_instance_name" {
  type = list(string)
}
variable "k8s_worker_private_ip" {
  type = list(string)
}
variable "passwd" {}
variable "ansible_path" {}
variable "gce_ssh_user" {}
variable "gce_ssh_pub_key_file" {}
