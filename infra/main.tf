# Empty on purpose — this is a skeleton, not a working Access setup yet.
#
# Add Cloudflare Zero Trust Access apps/policies here, e.g.:
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
