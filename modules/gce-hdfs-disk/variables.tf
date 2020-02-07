variable "project" {
  description = " Google Cloud Platform - Project "
  type = string
  default = "devopsbar20"
}

variable "zone" {
  description = " Zone "
  type = string
  default = "us-west1-a"
}

variable "disk_name" {
  description = "HDFS Disk Name"
  type = list(string)
  default = ["zookeeper-0", "zookeeper-1", "zookeeper-2", "hdfs-journalnode-k8s-0", "hdfs-journalnode-k8s-1", "hdfs-journalnode-k8s-2", "hdfs-namenode-k8s-0", "hdfs-namenode-k8s-1", "hdfs-krb5-k8s"]
}

variable "disk_size" {
  description = "HDFS Disk size"
  type = list(string)
  default = ["5", "5", "5", "20", "20", "20", "100", "100", "20"]
}
