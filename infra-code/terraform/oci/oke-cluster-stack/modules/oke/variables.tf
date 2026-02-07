variable "compartment_id" { type = string }
variable "cluster_name" { type = string }
variable "ssh_public_key_path" { type = string }
variable "vcn_cidr" {
  type    = string
  default = "10.10.0.0/16"
}

variable "control_plane_allowed_cidrs" {
  type        = list(string)
  description = "Lista de CIDRs autorizados a acessar o endpoint do control plane."
  default     = ["177.221.120.243/32"]
}

variable "cni_type" {
  type        = string
  description = "CNI do cluster: 'flannel' (overlay) ou 'npn' (VCN-Native / OCI_VCN_IP_NATIVE)."
  default     = "npn"
}
