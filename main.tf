terraform {
  required_version = ">= 0.12.20"
}

provider "google" {
  project     = var.project
  region      = var.region
  zone        = var.zone
  version     = "~> 3.7"
  credentials = file("/root/.ssh/credential.json")
}

module "gce-k8s-master" {
  source                   = "./modules/gce-k8s-master"
  project                  = var.project
  region                   = var.region
  machine_type             = var.machine_type
  zone                     = var.zone
  image                    = var.image
  k8s_master_instance_name = var.k8s_master_instance_name
  k8s_master_private_ip    = var.k8s_master_private_ip
  passwd                   = var.passwd
  ansible_path             = var.ansible_path
  gce_ssh_user             = var.gce_ssh_user
  gce_ssh_pub_key_file     = var.gce_ssh_pub_key_file
}

module "gce-k8s-worker" {
  source                   = "./modules/gce-k8s-worker"
  project                  = var.project
  region                   = var.region
  machine_type             = var.machine_type
  zone                     = var.zone
  image                    = var.image
  k8s_worker_instance_name = var.k8s_worker_instance_name
  k8s_worker_private_ip    = var.k8s_worker_private_ip
  passwd                   = var.passwd
  ansible_path             = var.ansible_path
  gce_ssh_user             = var.gce_ssh_user
  gce_ssh_pub_key_file     = var.gce_ssh_pub_key_file
}

module "gce-hdfs-disk" {
  source = "./modules/gce-hdfs-disk"
  project = var.project
  zone = var.zone
  disk_name = var.disk_name
  disk_size = var.disk_size
}

data "template_file" "ansible_hosts" {
  template   = file("${path.module}/ansible_hosts")
  depends_on = [module.gce-k8s-master, module.gce-k8s-worker]

  vars = {
    k8s-master-ip = "${join("\n", module.gce-k8s-master.k8s_master_ip_addr.*)}"
    k8s-worker-ip = "${join("\n", module.gce-k8s-worker.k8s_worker_ip_addr.*)}"
  }
}

resource "null_resource" "ansible-hosts" {
  triggers = {
    template_rendered = data.template_file.ansible_hosts.rendered
  }
  provisioner "local-exec" {
    command = "echo '${data.template_file.ansible_hosts.rendered}' > '${var.ansible_path}/hosts'"
  }
}



resource "null_resource" "ansible-play" {
  depends_on = [module.gce-k8s-master, module.gce-k8s-worker, module.gce-hdfs-disk, null_resource.ansible-hosts]

  provisioner "local-exec" {
    command = <<EOT
sleep 30s
$master
$worker
$postconfig
$hdfsdeploy
EOT

    environment = {
      master     = "ansible-playbook -i ${var.ansible_path}/hosts ${var.ansible_path}/setup_master_node.yml"
      worker     = "ansible-playbook -i ${var.ansible_path}/hosts ${var.ansible_path}/setup_worker_nodes.yml"
      postconfig = "ansible-playbook -i ${var.ansible_path}/hosts ${var.ansible_path}/post_configure_nodes.yml"
      hdfsdeploy = "ansible-playbook -i ${var.ansible_path}/hosts ${var.ansible_path}/setup_hdfs_nodes.yml"
    }
  }
}

/*

resource "null_resource" "ansible-play-post" {
  depends_on = [null_resource.ansible-play]
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = <<EOT
$hdfsdeploy
EOT

    environment = {
      hdfsdeploy = "ansible-playbook -i ${var.ansible_path}/hosts ${var.ansible_path}/setup_hdfs_nodes.yml"
    }
  }
}

*/
