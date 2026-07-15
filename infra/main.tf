# Empty on purpose — this is a skeleton, not working resources yet.
#
# Add Cloudflare resources here as the project needs them, e.g. a D1
# database or Zero Trust Access apps/policies:
#
# resource "cloudflare_d1_database" "example" {
#   account_id = var.cloudflare_account_id
#   name       = "example"
#
#   # Cloudflare's API always returns this as an object (never null) once
#   # the database exists. Left undeclared, Terraform's plan tries to
#   # "correct" it to null on every apply, and the API rejects that PUT
#   # with 400 Invalid property: read_replication => Expected object,
#   # received null. Pin it to the API's own default so there's no drift.
#   read_replication = {
#     mode = "disabled"
#   }
# }
#
# If a resource's generated ID needs to land in wrangler.jsonc (like a D1
# database_id), add a matching output in outputs.tf — see the commented
# example there and README.md "Wiring a Terraform-provisioned ID into
# wrangler.jsonc".
#
# resource "cloudflare_zero_trust_access_application" "example" {
#   account_id = var.cloudflare_account_id
#   name       = "example"
#   domain     = "example.<your-domain>.com"
#   type       = "self_hosted"
# }
#
# resource "cloudflare_zero_trust_access_policy" "example" {
#   account_id     = var.cloudflare_account_id
#   application_id = cloudflare_zero_trust_access_application.example.id
#   name           = "example-policy"
#   decision       = "allow"
#
#   include {
#     email_domain = ["your-domain.com"]
#   }
# }
