# Infra (Terraform)

Cloudflare resources for this project — D1 databases, KV namespaces, R2
buckets, Durable Objects, and Zero Trust Access apps/policies once
auth-gated routes exist — live here as Terraform, not created ad hoc via
the dashboard or `wrangler d1 create`/`wrangler kv namespace create`/etc.
See the root `CLAUDE.md`. This is currently a **skeleton**: `main.tf` has
no resources yet, add them there as the project needs them.

State is stored in a Cloudflare R2 bucket (S3-compatible), so it survives
between local runs and CI runs. Nothing here provisions that bucket —
create it once, manually, before the first `terraform init` (chicken-and-egg:
Terraform needs a backend to exist before it can manage anything).

**One bucket can hold state for multiple projects cloned from this
template.** Isolation comes from the state file's `key` (path) inside the
bucket, not from having a separate bucket per project — `provider.tf`
deliberately doesn't hardcode a key. `init.sh` and the CI workflow both
derive it from `package.json`'s `name` (`<project>/terraform.tfstate`), so
as long as each project was renamed via the `init-template` skill, they
won't collide. Override with `TF_STATE_KEY` if you want something else.
Reusing a bucket just means step 1 below only needs doing once per
Cloudflare account, not once per project.

## One-time setup (per Cloudflare account)

1. Create the state bucket:
   ```
   npx wrangler r2 bucket create <project>-tfstate
   ```
   `init.sh` and `.github/workflows/main.yml` assume an EU jurisdiction
   bucket (endpoint `<account-id>.eu.r2.cloudflarestorage.com`) — pass
   `--jurisdiction eu` when creating it, or update the endpoint in both
   files if the bucket isn't jurisdiction-restricted (plain
   `<account-id>.r2.cloudflarestorage.com`). `region` is always `"auto"`
   regardless of jurisdiction — R2's S3-compatible API only accepts
   `wnam`/`enam`/`weur`/`eeur`/`apac`/`oc`/`auto`, not `"eu"`.
2. Create an R2 API token scoped to that bucket (Cloudflare dashboard →
   R2 → **Manage R2 API Tokens** → Create API Token → Object Read & Write,
   scoped to `<project>-tfstate`). Save the Access Key ID and Secret Access
   Key it gives you — shown once.
3. Add these as **GitHub repo secrets** (Settings → Secrets and variables →
   Actions) so `.github/workflows/main.yml` can run `terraform apply` on
   push to main:
   - `CLOUDFLARE_API_TOKEN` — Cloudflare API token for the provider itself.
     Scope it to whatever resource types `main.tf` actually manages (e.g.
     D1: Edit, Zero Trust Access: Edit). Same token is also used for
     `wrangler deploy` in CI (and `wrangler d1 migrations apply`, once a
     project has D1 migrations), so it needs Workers Scripts: Edit and
     D1: Edit for those too — or use a separate narrower token, your call.
   - `CLOUDFLARE_ACCOUNT_ID`
   - `TF_STATE_BUCKET` — the bucket name from step 1.
   - `R2_ACCESS_KEY_ID` / `R2_SECRET_ACCESS_KEY` — from step 2.

   `./infra/set-github-secrets.sh` sets all five via `gh secret set` —
   picks up values already in your shell env (see "Running locally" below),
   prompts with hidden input for anything missing, and pushes nothing to
   the repo. Requires `gh auth login` first. Pass `owner/repo` as an
   argument if it can't infer the repo from the current git remote.

## Wiring a Terraform-provisioned ID into wrangler.jsonc

Some resources (a D1 database, a KV namespace, an R2 bucket...) only get
their real ID after `terraform apply` — `wrangler.jsonc` can't hardcode one
upfront. The pattern this template wires up (see the commented D1 example
in `main.tf`/`outputs.tf` and `.github/workflows/main.yml`):

1. Add the resource in `main.tf` and a matching `output` in `outputs.tf`.
2. Add the binding to `wrangler.jsonc` yourself, with a placeholder ID
   (`00000000-0000-0000-0000-000000000000`) — it isn't meant to be
   hand-edited afterwards.
3. **CI**: the `terraform` job runs before `deploy-worker` and exposes any
   matching output (e.g. `d1_database_id`) as a job output; `deploy-worker`
   patches it into `wrangler.jsonc` with `jq` right before `wrangler
   deploy`, but only if that output is non-empty — projects that haven't
   added the resource yet just skip the patch step. The committed
   placeholder is never actually deployed.
   - **Local dev/tests**: `wrangler dev`, `astro dev`, and
     `@cloudflare/vitest-pool-workers` all talk to local emulation
     (Miniflare/`--local`) that doesn't care whether the ID matches a real
     remote resource — the placeholder works fine for these.
   - **Manual remote deploy** (outside CI): run `terraform apply` here
     first, then patch `wrangler.jsonc` yourself with `terraform output
     -raw <output-name>` before `wrangler deploy` — don't create the
     resource by hand via `wrangler d1 create`/`wrangler kv namespace
     create`/etc., it'd create an untracked duplicate outside Terraform.

## Running locally

Set these on your **host**, before the devcontainer starts — it forwards
them in via `remoteEnv` in `.devcontainer/devcontainer.json` (which also
renames `R2_ACCESS_KEY_ID`/`R2_SECRET_ACCESS_KEY` to the `AWS_*` names
Terraform's S3-compatible backend expects; no AWS account involved, see the
comment there):

```sh
export CLOUDFLARE_API_TOKEN="..."
export CLOUDFLARE_ACCOUNT_ID="..."
export TF_STATE_BUCKET="<project>-tfstate"
export R2_ACCESS_KEY_ID="<R2 access key id>"
export R2_SECRET_ACCESS_KEY="<R2 secret access key>"
```

Rebuild/reopen the devcontainer so `remoteEnv` picks them up, then inside
the container alias the two Terraform needs as `TF_VAR_*` (add to your shell
profile so it's not a one-off):

```sh
export TF_VAR_cloudflare_api_token="$CLOUDFLARE_API_TOKEN"
export TF_VAR_cloudflare_account_id="$CLOUDFLARE_ACCOUNT_ID"
```

Then:

```sh
./infra/init.sh   # generates backend.hcl (gitignored) + terraform init
terraform -chdir=infra plan
terraform -chdir=infra apply
```

CI does the same thing (see `.github/workflows/main.yml`) using the GitHub
secrets from the setup above instead of local env vars.
