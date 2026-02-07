terraform {
  required_version = ">= 1.5.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.0.0"
    }
  }
}

provider "oci" {
  region = "sa-saopaulo-1"
}

provider "oci" {
  alias  = "home"
  region = var.home_region
}
