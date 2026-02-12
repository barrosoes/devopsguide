output "system_node_pool_id" {
  description = "OCID of the system node pool."
  value       = oci_containerengine_node_pool.system_pool.id
}

output "workload_node_pool_id" {
  description = "OCID of the workload node pool."
  value       = oci_containerengine_node_pool.workload_pool.id
}

output "node_pool_ids" {
  description = "Node pool OCIDs grouped for automation."
  value = {
    system   = oci_containerengine_node_pool.system_pool.id
    workload = oci_containerengine_node_pool.workload_pool.id
  }
}

output "node_pool_names" {
  description = "Node pool names grouped for automation."
  value = {
    system   = oci_containerengine_node_pool.system_pool.name
    workload = oci_containerengine_node_pool.workload_pool.name
  }
}
