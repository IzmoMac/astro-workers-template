variable "cloudflare_api_token" {
  description = "Cloudflare API token used by the Cloudflare provider — scope it to whatever resource types main.tf actually manages (e.g. D1: Edit, Zero Trust Access: Edit)."
  type        = string
  sensitive   = true
}

variable "cloudflare_account_id" {
  description = "Cloudflare account ID that owns the resources managed here."
  type        = string
}
