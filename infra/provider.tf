terraform {
  required_version = ">= 1.9.0"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }

  # Partial backend config on purpose — no account-specific values are
  # committed. Real values (bucket, key, region, endpoint) are supplied at
  # `terraform init -backend-config=backend.hcl` time. `key` is deliberately
  # NOT hardcoded here: if this bucket is shared across multiple projects
  # cloned from this template, each one needs a distinct key or their state
  # files collide and overwrite each other. `region` isn't hardcoded either
  # (R2 buckets can be jurisdiction-restricted, e.g. "eu" instead of
  # "auto", with a matching jurisdiction-specific endpoint) — and Terraform
  # errors if an attribute is set both here and via -backend-config, so it
  # can't be fixed to "auto" here anyway. See README.md.
  backend "s3" {
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = true
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
