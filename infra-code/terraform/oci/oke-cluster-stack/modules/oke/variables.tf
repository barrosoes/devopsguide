variable "compartment_id" { type = string }
variable "cluster_name" { type = string }
variable "ssh_public_key_path" { type = string }

# Tags (pass-through para o módulo oracle-terraform-modules/oke/oci).
# Estrutura esperada (exemplos):
# freeform_tags = {
#   cluster = { test = "pipeline" }
#   network = {}
# }
variable "freeform_tags" {
  type        = any
  description = "Freeform tags por componente (cluster/network/workers/etc.) - pass-through."
  default     = {}
}

variable "defined_tags" {
  type        = any
  description = "Defined tags por componente (cluster/network/workers/etc.)."
  default     = {}
}
variable "vcn_cidr" {
  type    = string
  default = "10.10.0.0/16"
}

variable "control_plane_allowed_cidrs" {
  type        = list(string)
  description = "Lista de CIDRs autorizados a acessar o endpoint do control plane."
  default     = ["0.0.0.0/0"]
}

variable "cni_type" {
  type        = string
  description = "CNI do cluster: 'flannel' (overlay) ou 'npn' (VCN-Native / OCI_VCN_IP_NATIVE)."
  default     = "npn"
}
