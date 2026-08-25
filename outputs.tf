output "kubeconfig_path" {
  value = local_file.kubeconfig.filename
}

output "talosconfig_path" {
  value = local_file.talosconfig.filename
}

output "next_steps" {
  value = <<-EOT
    export TALOSCONFIG=${abspath(local_file.talosconfig.filename)}
    export KUBECONFIG=${abspath(local_file.kubeconfig.filename)}
    talosctl health --nodes ${var.node_ip}
    kubectl get nodes
  EOT
}