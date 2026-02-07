data "oci_identity_availability_domains" "ads" {
  compartment_id = coalesce(var.tenancy_ocid, var.compartment_id)
}

data "oci_containerengine_node_pool_option" "all" {
  node_pool_option_id = "all"
  compartment_id      = var.compartment_id
}

locals {
  nodepool_ad = coalesce(var.availability_domain, try(data.oci_identity_availability_domains.ads.availability_domains[0].name, null))

  # Tentativa de escolher automaticamente uma imagem OKE-ready
  # (se falhar, o usuário deve informar var.node_image_id)
  node_pool_option_image_id = coalesce(
    try(data.oci_containerengine_node_pool_option.all.sources[0].image_id, null),
    null
  )

  # O provider pode retornar outros formatos; garantimos que só aceitamos OCID.
  node_image_id = coalesce(
    var.node_image_id,
    (startswith(local.node_pool_option_image_id, "ocid1.image.") ? local.node_pool_option_image_id : null)
  )
}

resource "oci_containerengine_node_pool" "system_pool" {
  cluster_id     = var.cluster_id
  compartment_id = var.compartment_id
  name           = "system-pool"
  node_shape     = "VM.Standard.E4.Flex"

  node_source_details {
    source_type             = "IMAGE"
    image_id                = local.node_image_id
    boot_volume_size_in_gbs = 50
  }

  node_shape_config {
    ocpus         = 2
    memory_in_gbs = 16
  }

  lifecycle {
    precondition {
      condition     = var.cni_type != "npn" || var.pods_subnet_id != null
      error_message = "Para cni_type='npn' (OCI_VCN_IP_NATIVE), informe pods_subnet_id no módulo nodepools."
    }
    precondition {
      condition     = local.node_image_id != null
      error_message = "Informe node_image_id (OCID de uma imagem OKE-ready) para criar node pools. Falhou a seleção automática via node_pool_option."
    }
  }

  node_config_details {
    size    = var.system_size
    nsg_ids = var.worker_nsg_ids
    placement_configs {
      availability_domain = local.nodepool_ad
      subnet_id           = var.nodes_subnet_id
    }

    dynamic "node_pool_pod_network_option_details" {
      for_each = var.cni_type == "npn" ? [1] : []
      content {
        cni_type          = "OCI_VCN_IP_NATIVE"
        pod_subnet_ids    = [var.pods_subnet_id]
        pod_nsg_ids       = var.pod_nsg_ids
        max_pods_per_node = var.max_pods_per_node
      }
    }
  }
}

resource "oci_containerengine_node_pool" "workload_pool" {
  cluster_id     = var.cluster_id
  compartment_id = var.compartment_id
  name           = "workload-pool"
  node_shape     = "VM.Standard.E4.Flex"

  node_source_details {
    source_type             = "IMAGE"
    image_id                = local.node_image_id
    boot_volume_size_in_gbs = 50
  }

  node_shape_config {
    ocpus         = 2
    memory_in_gbs = 16
  }

  lifecycle {
    precondition {
      condition     = var.cni_type != "npn" || var.pods_subnet_id != null
      error_message = "Para cni_type='npn' (OCI_VCN_IP_NATIVE), informe pods_subnet_id no módulo nodepools."
    }
    precondition {
      condition     = local.node_image_id != null
      error_message = "Informe node_image_id (OCID de uma imagem OKE-ready) para criar node pools. Falhou a seleção automática via node_pool_option."
    }
  }

  node_config_details {
    size    = var.workload_size
    nsg_ids = var.worker_nsg_ids
    placement_configs {
      availability_domain = local.nodepool_ad
      subnet_id           = var.nodes_subnet_id
    }

    dynamic "node_pool_pod_network_option_details" {
      for_each = var.cni_type == "npn" ? [1] : []
      content {
        cni_type          = "OCI_VCN_IP_NATIVE"
        pod_subnet_ids    = [var.pods_subnet_id]
        pod_nsg_ids       = var.pod_nsg_ids
        max_pods_per_node = var.max_pods_per_node
      }
    }
  }
}
