variable "cluster_name" {
  type    = string
  default = "homelab"
}

variable "node_ip" {
  type        = string
  description = "Static IP for the control plane node"
}

variable "gateway" {
  type = string
}

variable "node_mac" {
  type        = string
  description = "MAC of the primary NIC, used for deviceSelector"
}

variable "install_disk" {
  type    = string
  default = "/dev/nvme0n1"
}

variable "talos_version" {
  type    = string
  default = "v1.13.9"
}

variable "hostname" {
  type    = string
  default = "talos-cp1"
}