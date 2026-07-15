#!/usr/bin/env bash
# Sets the GitHub repo secrets .github/workflows/main.yml needs for the
# deploy-worker and terraform jobs. See README.md "One-time setup" for what
# each one is and how to obtain it.
#
# Usage: ./infra/set-github-secrets.sh [owner/repo]
#   owner/repo defaults to the repo gh detects from the current git remote.
#
# Values are taken from the environment when already set (handy if you've
# exported the same vars infra/init.sh and the devcontainer use), otherwise
# you're prompted with hidden input. Nothing is echoed or logged.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

command -v gh >/dev/null 2>&1 || {
  echo "gh CLI not found — see https://cli.github.com" >&2
  exit 1
}
gh auth status >/dev/null 2>&1 || {
  echo "Not logged in to gh — run 'gh auth login' first." >&2
  exit 1
}

REPO_ARGS=()
if [ -n "${1:-}" ]; then
  REPO_ARGS=(--repo "$1")
fi

require_secret() {
  local var_name="$1" prompt_text="$2"
  local value="${!var_name:-}"

  if [ -z "$value" ]; then
    read -rsp "$prompt_text: " value
    echo >&2
  fi

  if [ -z "$value" ]; then
    echo "Error: $var_name must not be empty." >&2
    exit 1
  fi

  printf '%s' "$value" | gh secret set "$var_name" "${REPO_ARGS[@]}"
  echo "Set $var_name" >&2
}

require_secret CLOUDFLARE_API_TOKEN "Cloudflare API token (scope to what main.tf manages, e.g. D1: Edit, Zero Trust Access: Edit; add Workers Scripts: Edit too if reusing it for wrangler deploy)"
require_secret CLOUDFLARE_ACCOUNT_ID "Cloudflare account ID"
require_secret TF_STATE_BUCKET "Terraform state R2 bucket name"
require_secret R2_ACCESS_KEY_ID "R2 API token Access Key ID"
require_secret R2_SECRET_ACCESS_KEY "R2 API token Secret Access Key"

echo "Done. Verify with: gh secret list ${REPO_ARGS[*]}"
