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

variable "extraManifests" {
  type        = list(string)
  description = "List of links to extra manifests to include in the cluster on bootstrap"
}

variable "argo_repo_url" {
  type        = string
  description = "Git repo Argo watches for the app-of-apps"
}

variable "argo_target_revision" {
  type    = string
  default = "main"
}

variable "argo_path" {
  type    = string
  default = "apps"
}

variable "argo_repo_ssh_private_key_path" {
  description = "Path to an SSH deploy key for authenticating to a private argo_repo_url. If the file doesn't exist, repo credentials are skipped (e.g. for a public repo)."
  type        = string
  default     = "./local/argo_repo_deploy_key"
}
