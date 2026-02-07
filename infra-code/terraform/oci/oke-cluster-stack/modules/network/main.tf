module "vcn" {
  source  = "oracle-terraform-modules/vcn/oci"
  version = "3.6.0"

  compartment_id = var.compartment_id

  vcn_name  = "oke-vcn"
  vcn_cidrs = [var.vcn_cidr]

  create_internet_gateway = true
  create_nat_gateway      = true
  create_service_gateway  = true

  subnets = {
    api   = { cidr_block = "10.10.10.0/24", private = false }
    nodes = { cidr_block = "10.10.20.0/24", private = true }
    pods  = { cidr_block = "10.10.30.0/24", private = true }
    lb    = { cidr_block = "10.10.40.0/24", private = false }
  }
}
