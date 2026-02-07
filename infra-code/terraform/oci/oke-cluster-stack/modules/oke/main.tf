locals {
  # Regras de DNS label na OCI: 1-15 chars, alfanumérico, começa com letra.
  # Ex.: "oke-cluster" -> "okecluster"
  # (o display_name pode ter hífen; o dns_label não)
  # Obs.: evitamos `regexreplace` para compatibilidade.
  oci_dns_label = substr(
    lower(
      replace(
        replace(
          replace(var.cluster_name, "-", ""),
          "_",
          ""
        ),
        ".",
        ""
      )
    ),
    0,
    15
  )

  # O módulo `oracle-terraform-modules/oke/oci` espera tags em uma estrutura
  # "por componente". Mantemos todos os campos para evitar access errors quando
  # o módulo ler chaves ausentes.
  _default_component_tags = {
    bastion           = {}
    cluster           = {}
    iam               = {}
    network           = {}
    operator          = {}
    persistent_volume = {}
    service_lb        = {}
    workers           = {}
  }

  freeform_tags = merge(local._default_component_tags, var.freeform_tags)
  defined_tags  = merge(local._default_component_tags, var.defined_tags)
}

module "oke_cluster" {
  source  = "oracle-terraform-modules/oke/oci"
  version = "5.3.2"

  providers = {
    oci      = oci
    oci.home = oci.home
  }

  compartment_id = var.compartment_id
  cluster_name   = var.cluster_name

  # Nomes fixos (evita sufixo aleatório tipo "oke-ktdqjz")
  state_id      = local.oci_dns_label
  vcn_name      = "${var.cluster_name}-vcn"
  vcn_dns_label = local.oci_dns_label

  # IAM resources are optional in this module; keep disabled here.
  create_iam_resources = false

  # One-step apply: let this module create VCN + subnets
  create_vcn = true
  vcn_cidrs  = [var.vcn_cidr]

  # Nomes fixos para subnets
  subnets = {
    # Mapeamento do seu padrão antigo: api/nodes/pods/lb
    # - api   -> cp
    # - nodes -> workers
    # - lb    -> pub_lb
    # IMPORTANTE: manter `newbits` para o módulo conseguir calcular os CIDRs.
    # (valores padrão do módulo: cp=13, workers=4, pods=2, pub_lb/int_lb=11, bastion/operator=13)
    cp      = { create = "auto", newbits = "13", display_name = "sub-api-oke", dns_label = "cp" }
    workers = { create = "auto", newbits = "4", display_name = "sub-nodes-oke", dns_label = "wk" }
    pods    = { create = "auto", newbits = "2", display_name = "sub-pods-oke", dns_label = "po" }
    pub_lb  = { create = "auto", newbits = "11", display_name = "sub-lb-oke", dns_label = "pl" }

    # Não usados neste setup
    int_lb   = { create = "never", newbits = "11", dns_label = "il" }
    bastion  = { create = "never", newbits = "13", dns_label = "ba" }
    operator = { create = "never", newbits = "13", dns_label = "op" }
  }

  # Não criar VMs auxiliares
  create_bastion  = false
  create_operator = false

  # Cluster settings
  kubernetes_version = "v1.34.2"
  cluster_type       = "enhanced"
  cni_type           = var.cni_type

  # Public control plane endpoint, restricted by allowed CIDRs
  control_plane_is_public           = true
  assign_public_ip_to_control_plane = true
  # Inclui o CIDR da VCN para permitir que os workers/pods registrem no control plane.
  control_plane_allowed_cidrs = distinct(concat(var.control_plane_allowed_cidrs, [var.vcn_cidr]))

  # Use only public load balancers (maps to `pub_lb`)
  load_balancers          = "public"
  preferred_load_balancer = "public"

  ssh_public_key_path = var.ssh_public_key_path

  freeform_tags = local.freeform_tags
  defined_tags  = local.defined_tags
}
