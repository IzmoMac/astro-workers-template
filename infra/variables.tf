variable "cloudflare_api_token" {
  description = "Cloudflare API token used by the Cloudflare provider (needs Zero Trust Access: Edit)."
  type        = string
  sensitive   = true
}

variable "cloudflare_account_id" {
  description = "Cloudflare account ID that owns the Zero Trust Access apps/policies managed here."
  type        = string
}
