locals {
  gitops_repo_ssh_private_key = fileexists(var.gitops_repo_ssh_private_key_path) ? file(var.gitops_repo_ssh_private_key_path) : null
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = true

  values = var.helm_values
}

resource "kubectl_manifest" "gitops_repo_credentials" {
  count = var.gitops_repo_url != "" && local.gitops_repo_ssh_private_key != null ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "v1"
    kind       = "Secret"
    metadata = {
      name      = "gitops-repo-credentials"
      namespace = var.namespace
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

resource "kubectl_manifest" "bootstrap_app" {
  count = var.gitops_repo_url != "" ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = var.bootstrap_app_name
      namespace = var.namespace
    }
    finalizers = [ "resources-finalizer.argocd.argoproj.io"]
    spec = {
      project = "default"
      source = {
        repoURL        = var.gitops_repo_url
        targetRevision = var.gitops_repo_revision
        path           = var.gitops_repo_path
      }
      directory = {
        recurse = true
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = var.namespace
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = ["CreateNamespace=false"]
      }
    }
  })

  depends_on = [helm_release.argocd, kubectl_manifest.gitops_repo_credentials]
}
