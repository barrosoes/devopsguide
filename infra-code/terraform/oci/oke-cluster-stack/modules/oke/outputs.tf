output "cluster_id" { value = module.oke_cluster.cluster_id }

output "vcn_id" { value = module.oke_cluster.vcn_id }
output "control_plane_subnet_id" { value = module.oke_cluster.control_plane_subnet_id }
output "worker_subnet_id" { value = module.oke_cluster.worker_subnet_id }
output "pod_subnet_id" { value = module.oke_cluster.pod_subnet_id }
output "pub_lb_subnet_id" { value = module.oke_cluster.pub_lb_subnet_id }
