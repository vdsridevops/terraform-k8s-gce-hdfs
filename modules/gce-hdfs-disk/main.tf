resource "google_compute_disk" "default" {
  count     = length(var.disk_name)
  name      = var.disk_name[count.index]
  type      = "pd-standard"
  zone      = var.zone
  project   = var.project
  size      = var.disk_size[count.index]
}
