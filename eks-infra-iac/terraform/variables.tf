variable "region" {
  type    = string
  default = "eu-west-3"
}

variable "cluster_name" {
  type    = string
  default = "dev-cluster"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "az_count" {
  type    = number
  default = 2
}

variable "node_types" {
  type    = list(string)
  default = ["t3.small"]
}

variable "node_desired" {
  type    = number
  default = 3
}

variable "node_min" {
  type    = number
  default = 3
}

variable "node_max" {
  type    = number
  default = 5
}

variable "node_disk_gib" {
  type    = number
  default = 30
}

variable "tags" {
  type = map(string)
  default = {
    Project   = "DevOpsShack"
    ManagedBy = "Terraform"
  }
}

