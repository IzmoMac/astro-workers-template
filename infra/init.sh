#!/usr/bin/env bash
# Generates backend.hcl from env vars and runs `terraform init`.
# Mirrors what .github/workflows/main.yml does in CI — see README.md for
# which env vars need to be set and where they come from.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

: "${TF_STATE_BUCKET:?set TF_STATE_BUCKET (R2 bucket name for Terraform state)}"
: "${CLOUDFLARE_ACCOUNT_ID:?set CLOUDFLARE_ACCOUNT_ID}"

# Defaults to the package.json name so multiple projects can share one
# bucket without their state files colliding. Override with TF_STATE_KEY if
# you want something else.
TF_STATE_KEY="${TF_STATE_KEY:-$(node -p "require('../package.json').name")/terraform.tfstate}"

cat >backend.hcl <<EOF
bucket = "${TF_STATE_BUCKET}"
key    = "${TF_STATE_KEY}"
region = "auto"

endpoints = {
  s3 = "https://${CLOUDFLARE_ACCOUNT_ID}.eu.r2.cloudflarestorage.com"
}
EOF

terraform init -backend-config=backend.hcl "$@"
