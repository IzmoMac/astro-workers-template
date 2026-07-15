# Empty on purpose — no resources are provisioned yet (see main.tf).
#
# Uncomment once a resource whose generated ID needs to be wired into
# wrangler.jsonc exists in main.tf (e.g. the commented D1 example there).
# CI's `terraform` job reads outputs like this to patch wrangler.jsonc
# before `deploy-worker` runs — see README.md "Wiring a
# Terraform-provisioned ID into wrangler.jsonc".
#
# output "d1_database_id" {
#   value = cloudflare_d1_database.example.id
# }
#
# output "session_kv_namespace_id" {
#   value = cloudflare_workers_kv_namespace.session.id
# }
