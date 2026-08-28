variable "kubeconfig_path" {
  description = "Path to the kubeconfig file handed off by the infra repo that provisions the VM and installs Talos."
  type        = string
  default     = "../local/kubeconfig"
}

variable "namespace" {
  description = "Namespace to install ArgoCD into."
  type        = string
  default     = "argocd"
}

variable "chart_version" {
  description = "Pinned version of the argo-cd Helm chart (argoproj/argo-helm)."
  type        = string
}

variable "helm_values" {
  description = "Additional raw YAML values passed to the argo-cd Helm release."
  type        = list(string)
  default     = []
}

variable "gitops_repo_url" {
  description = "Git repository URL for ArgoCD's bootstrap app-of-apps Application. Leave empty to skip creating it."
  type        = string
  default     = ""
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

variable "bootstrap_app_name" {
  description = "Name of the seed app-of-apps Application resource."
  type        = string
  default     = "root"
}

variable "gitops_repo_ssh_private_key_path" {
  description = "Path to the SSH private key (deploy key) for authenticating to a private gitops_repo_url. Leave null to skip creating repo credentials (e.g. for a public repo)."
  type        = string
  default     = null
  sensitive   = true
}
