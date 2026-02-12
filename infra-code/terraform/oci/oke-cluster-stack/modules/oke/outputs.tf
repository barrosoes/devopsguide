output "cluster_id" { value = module.oke_cluster.cluster_id }

output "cluster_endpoints" {
  description = "OKE cluster endpoints (public/private)."
  value       = module.oke_cluster.cluster_endpoints
}

output "cluster_oidc_discovery_endpoint" {
  description = "OIDC discovery endpoint (when enabled)."
  value       = module.oke_cluster.cluster_oidc_discovery_endpoint
}

output "kubernetes_version" {
  description = "Kubernetes version configured for the cluster."
  value       = local.kubernetes_version
}

output "cni_type" {
  description = "CNI type configured for the cluster (npn/flannel)."
  value       = var.cni_type
}

output "vcn_id" { value = module.oke_cluster.vcn_id }
output "control_plane_subnet_id" { value = module.oke_cluster.control_plane_subnet_id }
output "worker_subnet_id" { value = module.oke_cluster.worker_subnet_id }
output "pod_subnet_id" { value = module.oke_cluster.pod_subnet_id }
output "pub_lb_subnet_id" { value = module.oke_cluster.pub_lb_subnet_id }

output "subnet_ids" {
  description = "Subnet IDs grouped for automation."
  value = {
    control_plane = module.oke_cluster.control_plane_subnet_id
    workers       = module.oke_cluster.worker_subnet_id
    pods          = module.oke_cluster.pod_subnet_id
    pub_lb        = module.oke_cluster.pub_lb_subnet_id
  }
}

# NSGs criados pelo módulo oficial OKE (úteis para anexar aos node pools e pods).
output "worker_nsg_id" { value = module.oke_cluster.worker_nsg_id }
output "pod_nsg_id" { value = module.oke_cluster.pod_nsg_id }

output "nsg_ids" {
  description = "NSG IDs grouped for automation."
  value = {
    workers = module.oke_cluster.worker_nsg_id
    pods    = module.oke_cluster.pod_nsg_id
  }
}
