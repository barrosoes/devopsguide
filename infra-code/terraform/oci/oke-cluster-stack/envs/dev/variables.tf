variable "compartment_id" { type = string }
variable "ssh_public_key_path" { type = string }

variable "vcn_cidr" {
  type    = string
  default = "10.20.0.0/16"
}

variable "home_region" {
  type        = string
  description = "Região home da tenancy (necessária para operações de IAM)."
  default     = "sa-saopaulo-1"
}

variable "tenancy_ocid" {
  type        = string
  description = "OCID da tenancy (usado para listar Availability Domains)."
  default     = null
}

variable "availability_domain" {
  type        = string
  description = "Availability Domain para os node pools. Se nulo, usa o primeiro AD retornado."
  default     = null
}

# Tag de teste para validar mudanças via pipeline (aplicada no componente "cluster").
variable "oke_freeform_tags" {
  type        = any
  description = "Freeform tags do módulo OKE (estrutura por componente)."
  default = {
    cluster = {
      test = "pipeline"
    }
  }
}
