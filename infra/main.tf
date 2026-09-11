# Empty on purpose — this is a skeleton, not working resources yet.
#
# Add Cloudflare resources here as the project needs them, e.g. a D1
# database or Zero Trust Access apps/policies:
#
# resource "cloudflare_d1_database" "example" {
#   account_id   = var.cloudflare_account_id
#   name         = "example"
#
#   # Restricts where this database's data is stored/processed. Defaults to
#   # EU for this template — see "Storage defaults to EU" in README.md.
#   # Takes precedence over primary_location_hint below if both are set.
#   jurisdiction = var.storage_jurisdiction
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
# resource "cloudflare_r2_bucket" "example" {
#   account_id   = var.cloudflare_account_id
#   name         = "example"
#
#   # "location" is only a best-effort initial-placement hint; "jurisdiction"
#   # is the actual data-residency guarantee. Both default to EU for this
#   # template — see "Storage defaults to EU" in README.md.
#   location     = "weur"
#   jurisdiction = var.storage_jurisdiction
# }
#
# @astrojs/cloudflare auto-enables Astro's KV-backed sessions (the SESSION
# binding) at build time regardless of whether the app calls Astro.session,
# and there's no adapter option to disable it. If wrangler.jsonc doesn't
# declare this binding, `wrangler deploy` "auto-provisions" a KV namespace
# for it — but only successfully once; every deploy after that fails with
# "a namespace with this account ID and title already exists [code:
# 10014]" because the auto-created namespace is untracked. Provision it
# here instead, the same way as the D1 example above — see README.md "KV
# session binding → wrangler.jsonc wiring":
#
# `cloudflare_workers_kv_namespace` has no `jurisdiction` argument in the
# Terraform provider (Cloudflare's KV jurisdiction restriction isn't
# exposed there as of provider v5) — the resource below is unrestricted
# even though this template defaults other storage to EU. To keep the
# SESSION namespace EU-only anyway, create it once out-of-band with
# `wrangler kv namespace create session --jurisdiction eu`, then adopt it
# into Terraform with `terraform import
# cloudflare_workers_kv_namespace.session <account_id>/<namespace_id>`
# instead of letting `terraform apply` create an unrestricted one. See
# "Storage defaults to EU" in README.md.
#
# resource "cloudflare_workers_kv_namespace" "session" {
#   account_id = var.cloudflare_account_id
#   title      = "session"
# }
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
