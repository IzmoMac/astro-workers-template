variable "cloudflare_api_token" {
  description = "Cloudflare API token used by the Cloudflare provider — scope it to whatever resource types main.tf actually manages (e.g. D1: Edit, Zero Trust Access: Edit)."
  type        = string
  sensitive   = true
}

variable "cloudflare_account_id" {
  description = "Cloudflare account ID that owns the resources managed here."
  type        = string
}

variable "storage_jurisdiction" {
  description = "Default Cloudflare data-residency jurisdiction for storage resources (D1, R2) provisioned here. This template defaults new projects to \"eu\" — override per-resource only when a project has an explicit reason to store data outside the EU. See infra/README.md \"Storage defaults to EU\"."
  type        = string
  default     = "eu"
}
