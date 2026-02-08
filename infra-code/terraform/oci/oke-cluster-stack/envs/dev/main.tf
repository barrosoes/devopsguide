module "oke" {
  source         = "../../modules/oke"
  compartment_id = var.compartment_id
  cluster_name   = "oke-dev"

  providers = {
    oci      = oci
    oci.home = oci.home
  }

  vcn_cidr = var.vcn_cidr

  ssh_public_key_path = var.ssh_public_key_path

  # Freeform tags do cluster (ex.: "test=pipeline-3")
  freeform_tags = var.oke_freeform_tags
}

module "nodepools" {
  source              = "../../modules/nodepools"
  compartment_id      = var.compartment_id
  cluster_id          = module.oke.cluster_id
  nodes_subnet_id     = module.oke.worker_subnet_id
  pods_subnet_id      = module.oke.pod_subnet_id
  worker_nsg_ids      = [module.oke.worker_nsg_id]
  pod_nsg_ids         = [module.oke.pod_nsg_id]
  tenancy_ocid        = var.tenancy_ocid
  availability_domain = var.availability_domain

  system_size   = 1
  workload_size = 2
  workload_min  = 2
  workload_max  = 5

}
