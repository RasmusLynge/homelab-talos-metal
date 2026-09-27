locals {
  gitops_repo_ssh_private_key = fileexists(var.gitops_repo_ssh_private_key_path) ? file(var.gitops_repo_ssh_private_key_path) : null
}

# fetching the config used for argocd in the gitops repo to make sure the same will be bootstrapped.
data "http" "argocd_config" {
  url = var.gitops_repo_argocd_config_url
}

locals {
  argocd = yamldecode(data.http.argocd_config.response_body)
}

resource "helm_release" "argocd" {
  name             = local.argocd.name
  repository       = local.argocd.repoURL
  chart            = local.argocd.chart
  version          = local.argocd.targetRevision
  namespace        = local.argocd.namespace
  create_namespace = true

  values = var.helm_values
}

# Creating the secret for the gitops repo credentials, which will be used by ArgoCD to access the GitOps repository.
resource "kubectl_manifest" "gitops_repo_credentials" {
  count = var.gitops_repo_url != "" && local.gitops_repo_ssh_private_key != null ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "v1"
    kind       = "Secret"
    metadata = {
      name      = "gitops-repo-credentials"
      namespace = local.argocd.namespace
      labels = {
        "argocd.argoproj.io/secret-type" = "repository"
      }
    }
    stringData = {
      type          = "git"
      url           = var.gitops_repo_url
      sshPrivateKey = local.gitops_repo_ssh_private_key
    }
  })

  depends_on = [helm_release.argocd]
}


# Bootstrap the cluster with the root ArgoCD application, which will then deploy the rest of the applications in the GitOps repository.
data "http" "bootstrap_app" {
  url = var.gitops_repo_argocd_bootstrap_app_url
}

data "kubectl_file_documents" "bootstrap" {
  content = data.http.bootstrap_app.response_body
}

resource "kubectl_manifest" "bootstrap_app" {
  for_each  = data.kubectl_file_documents.bootstrap.manifests
  yaml_body = each.value

  depends_on = [helm_release.argocd, kubectl_manifest.gitops_repo_credentials]
}
