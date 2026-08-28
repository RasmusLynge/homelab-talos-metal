terraform {
  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = "~> 0.9"
    }
  }
}

locals {
  argo_repo_ssh_private_key = fileexists(var.argo_repo_ssh_private_key_path) ? file(var.argo_repo_ssh_private_key_path) : null
  argocd_namespace = "argocd"

  repo_credentials_manifest = local.argo_repo_ssh_private_key != null ? [{
    name = "argocd-repo-credentials"
    contents = yamlencode({
      apiVersion = "v1"
      kind       = "Secret"
      metadata = {
        name      = "gitops-repo-credentials"
        namespace = local.argocd_namespace
        labels = {
          "argocd.argoproj.io/secret-type" = "repository"
        }
      }
      stringData = {
        type          = "git"
        url           = var.argo_repo_url
        sshPrivateKey = local.argo_repo_ssh_private_key
      }
    })
  }] : []

  bootstrap_app_manifest = var.argo_repo_url != "" ? [{
    name = "argocd-bootstrap-app"
    contents = yamlencode({
      apiVersion = "argoproj.io/v1alpha1"
      kind       = "Application"
      metadata = {
        name      = "root"
        namespace = local.argocd_namespace
      }
      spec = {
        project = "default"
        source = {
          repoURL        = var.argo_repo_url
          targetRevision = var.argo_target_revision
          path           = var.argo_path
        }
        destination = {
          server    = "https://kubernetes.default.svc"
          namespace = local.argocd_namespace
        }
        syncPolicy = {
          automated = {
            prune    = true
            selfHeal = true
          }
          syncOptions = ["CreateNamespace=true"]
        }
      }
    })
  }] : []

  argocd_namespace_manifest = [{
    name = "argocd-namespace"
    contents = yamlencode({
      apiVersion = "v1"
      kind       = "Namespace"
      metadata   = { name = local.argocd_namespace }
    })
  }]
}

resource "talos_machine_secrets" "this" {
  talos_version = var.talos_version
}

data "talos_machine_configuration" "cp" {
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${var.node_ip}:6443"
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  talos_version    = var.talos_version

  config_patches = [
    yamlencode({
      machine = {
        install = {
          disk = var.install_disk
        }
        network = {
          interfaces = [{
            deviceSelector = {
              hardwareAddr = var.node_mac
            }
            addresses = ["${var.node_ip}/24"]
            routes = [{
              network = "0.0.0.0/0"
              gateway = var.gateway
            }]
          }]
          nameservers = [var.gateway]
        }
      }
      cluster = {
        allowSchedulingOnControlPlanes = true
        network = {
          cni = {
            name = "none"
          }
        }
        proxy = {
          disabled = true
        }
        extraManifests = var.extraManifests
        inlineManifests = [
    {
      name = "argocd-root-app"
      contents = yamlencode({
        apiVersion = "argoproj.io/v1alpha1"
        kind       = "Application"
        metadata = {
          name      = "root"
          namespace = "argocd"
        }
        spec = {
          project = "default"
          source = {
            repoURL        = var.argo_repo_url
            targetRevision = var.argo_target_revision
            path           = var.argo_path
          }
          destination = {
            server    = "https://kubernetes.default.svc"
            namespace = "argocd"
          }
          syncPolicy = {
            automated = {
              prune    = true
              selfHeal = true
            }
          }
        }
      })
    }
  ]
      }
    })
  ]
}

resource "talos_machine_configuration_apply" "cp" {
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.cp.machine_configuration
  node                        = var.node_ip
}

resource "talos_machine_bootstrap" "this" {
  depends_on           = [talos_machine_configuration_apply.cp]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = var.node_ip
}

data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = [var.node_ip]
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on           = [talos_machine_bootstrap.this]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = var.node_ip
}

resource "local_file" "talosconfig" {
  content         = data.talos_client_configuration.this.talos_config
  filename        = "${path.module}/local/talosconfig"
  file_permission = "0600"
}

resource "local_file" "kubeconfig" {
  content         = talos_cluster_kubeconfig.this.kubeconfig_raw
  filename        = "${path.module}/local/kubeconfig"
  file_permission = "0600"
}