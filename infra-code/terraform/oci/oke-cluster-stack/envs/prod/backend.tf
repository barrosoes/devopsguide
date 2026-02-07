terraform {
  backend "s3" {
    bucket = "tfstate-oke-prod"
    key    = "prod/terraform.tfstate"
    # Backend "s3" do Terraform espera uma região AWS válida.
    # Isso não é a região da OCI; é apenas um valor necessário pelo backend.
    region = "us-east-1"

    # `endpoint` foi deprecado; use `endpoints.s3`.
    endpoints = {
      s3 = "https://gr5ugxwrsywe.compat.objectstorage.sa-saopaulo-1.oraclecloud.com"
    }
    #access_key                  = var.oci_s3_access_key
    #secret_key                  = var.oci_s3_secret_key
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    # Compatibilidade com APIs S3-compat (ex.: OCI Object Storage).
    # Evita enviar checksum/cabeçalhos não suportados por alguns provedores.
    skip_s3_checksum = true
    # `force_path_style` foi deprecado; use `use_path_style`.
    use_path_style = true
  }
}
