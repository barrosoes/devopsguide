output "cluster_id" {
  description = "OCID of the OKE cluster."
  value       = module.oke.cluster_id
}

output "cluster_endpoints" {
  description = "OKE cluster endpoints (public/private)."
  value       = module.oke.cluster_endpoints
}

output "cluster_oidc_discovery_endpoint" {
  description = "OIDC discovery endpoint (when enabled)."
  value       = module.oke.cluster_oidc_discovery_endpoint
}

output "kubernetes_version" {
  description = "Kubernetes version configured for the cluster."
  value       = module.oke.kubernetes_version
}

output "cni_type" {
  description = "CNI type configured for the cluster (npn/flannel)."
  value       = module.oke.cni_type
}

output "vcn_id" {
  description = "OCID of the VCN used by the cluster."
  value       = module.oke.vcn_id
}

output "subnet_ids" {
  description = "Subnet IDs grouped for automation."
  value       = module.oke.subnet_ids
}

output "nsg_ids" {
  description = "NSG IDs grouped for automation."
  value       = module.oke.nsg_ids
}

output "node_pool_ids" {
  description = "Node pool OCIDs grouped for automation."
  value       = module.nodepools.node_pool_ids
}

output "node_pool_names" {
  description = "Node pool names grouped for automation."
  value       = module.nodepools.node_pool_names
}

output "stack_outputs" {
  description = "Aggregated outputs for scripts/automation (non-sensitive)."
  value = {
    cluster = {
      id                 = module.oke.cluster_id
      endpoints          = module.oke.cluster_endpoints
      oidc_discovery     = module.oke.cluster_oidc_discovery_endpoint
      kubernetes_version = module.oke.kubernetes_version
      cni_type           = module.oke.cni_type
      vcn_id             = module.oke.vcn_id
      subnet_ids         = module.oke.subnet_ids
      nsg_ids            = module.oke.nsg_ids
    }
    nodepools = {
      ids   = module.nodepools.node_pool_ids
      names = module.nodepools.node_pool_names
    }
  }
}
