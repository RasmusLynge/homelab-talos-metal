variable "kubeconfig_path" {
  description = "Path to the kubeconfig file handed off by the infra repo that provisions the VM and installs Talos."
  type        = string
  default     = "../local/kubeconfig"
}

variable "helm_values" {
  description = "Additional raw YAML values passed to the argo-cd Helm release."
  type        = list(string)
  default     = []
}

variable "gitops_repo_url" {
  description = "Git repository URL for ArgoCD's bootstrap app-of-apps Application."
  type        = string
}

variable "gitops_repo_revision" {
  description = "Git revision (branch, tag, HEAD, etc.)"
  type        = string
  default     = "HEAD"
}

variable "gitops_repo_path" {
  description = "Path within the GitOps repo the bootstrap Application should point at."
  type        = string
  default     = "."
}

variable "gitops_repo_ssh_private_key_path" {
  description = "Path to the SSH private key (deploy key) for authenticating to a private gitops_repo_url. Leave null to skip creating repo credentials (e.g. for a public repo)."
  type        = string
  default     = null
  sensitive   = true
}

variable "gitops_repo_argocd_config_url" {
  description = "URL to the ArgoCD Helm chart config.yaml in the GitOps repo. This is used to fetch the same config used for ArgoCD in the GitOps repo to make sure the same will be bootstrapped."
  type        = string
}

variable "gitops_repo_argocd_bootstrap_app_url" {
  description = "URL to the bootstrap app-of-apps Application YAML in the GitOps repo."
  type        = string
}