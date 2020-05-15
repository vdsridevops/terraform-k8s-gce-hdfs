resource "google_compute_instance" "k8s_master" {
  name         = var.k8s_master_instance_name
  machine_type = var.machine_type
  tags         = [var.k8s_master_instance_name] 
  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  allow_stopping_for_update = true
  service_account {
    scopes = ["userinfo-email", "compute-rw", "storage-full"]
  }

  metadata = {
        startup-script = <<SCRIPT
        echo "${var.passwd}" | passwd --stdin root
        sed -i 's/PermitRootLogin no/PermitRootLogin yes/g' /etc/ssh/sshd_config
        sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
        systemctl restart sshd
        SCRIPT
        ssh-keys = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
    }

  network_interface {
    network       = "default"
    subnetwork    = "default"
    network_ip    = var.k8s_master_private_ip
    access_config {
    }
  }
}


resource "google_compute_firewall" "default" {
  name    = "k8s-master-allow-http"
  network = "https://www.googleapis.com/compute/v1/projects/${var.project}/global/networks/default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  target_tags = ["master-http"]

}
