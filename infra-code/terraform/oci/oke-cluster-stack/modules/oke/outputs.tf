output "cluster_id" { value = module.oke_cluster.cluster_id }

output "vcn_id" { value = module.oke_cluster.vcn_id }
output "control_plane_subnet_id" { value = module.oke_cluster.control_plane_subnet_id }
output "worker_subnet_id" { value = module.oke_cluster.worker_subnet_id }
output "pod_subnet_id" { value = module.oke_cluster.pod_subnet_id }
output "pub_lb_subnet_id" { value = module.oke_cluster.pub_lb_subnet_id }

# NSGs criados pelo módulo oficial OKE (úteis para anexar aos node pools e pods).
output "worker_nsg_id" { value = module.oke_cluster.worker_nsg_id }
output "pod_nsg_id" { value = module.oke_cluster.pod_nsg_id }
