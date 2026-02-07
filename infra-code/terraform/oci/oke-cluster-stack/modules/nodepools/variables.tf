variable "cluster_id" { type = string }
variable "compartment_id" { type = string }
variable "nodes_subnet_id" { type = string }

variable "tenancy_ocid" {
  type        = string
  default     = null
  description = "OCID da tenancy (necessário para listar Availability Domains). Se não informado, tentará usar compartment_id."
}

variable "availability_domain" {
  type        = string
  default     = null
  description = "Availability Domain para os node pools (ex.: '<tenancyShortName>:SA-SAOPAULO-1-AD-1'). Se nulo, usa o primeiro AD retornado."
}

variable "cni_type" {
  type        = string
  description = "CNI do cluster: 'flannel' (overlay) ou 'npn' (VCN-Native / OCI_VCN_IP_NATIVE)."
  default     = "npn"
}

variable "pods_subnet_id" {
  type        = string
  default     = null
  description = "Subnet OCID de pods (obrigatório quando cni_type='npn')."
}

variable "pod_nsg_ids" {
  type        = list(string)
  default     = []
  description = "NSGs opcionais para pods (VCN-Native)."
}

variable "max_pods_per_node" {
  type        = number
  default     = null
  description = "Máximo de pods por node (opcional, VCN-Native)."
}

variable "node_image_id" {
  type        = string
  default     = null
  description = "OCID da imagem para os nodes (node_source_details.image_id). Se nulo, tentará escolher automaticamente via node_pool_option."
}

variable "system_size" { type = number }
variable "workload_size" { type = number }

variable "workload_min" { type = number }
variable "workload_max" { type = number }
