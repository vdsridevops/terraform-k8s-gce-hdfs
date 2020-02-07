terraform {
  required_version = ">= 0.12.20"
}

provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
  version = "~> 3.7"
}

module "gce-k8s-master" {
  source = "./modules/gce-k8s-master"
}

module "gce-k8s-worker" {
  source = "./modules/gce-k8s-worker"
}

module "gce-hdfs-disk" {
  source = "./modules/gce-hdfs-disk"
}

data "template_file" "ansible_hosts" {
  template   = file("${path.module}/ansible_hosts")
  depends_on = [ module.gce-k8s-master, module.gce-k8s-worker ]

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
    command = "echo '${data.template_file.ansible_hosts.rendered}' > '${var.path}/hosts'"
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
EOT
   
    environment = {
      master       = "ansible-playbook -i ${var.path}/hosts ${var.path}/setup_master_node.yml"
      worker       = "ansible-playbook -i ${var.path}/hosts ${var.path}/setup_worker_nodes.yml"
      postconfig   = "ansible-playbook -i ${var.path}/hosts ${var.path}/post_configure_nodes.yml"
    }
  }
}



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
      hdfsdeploy   = "ansible-playbook -i ${var.path}/hosts ${var.path}/setup_hdfs_nodes.yml"
    }
  }
}

