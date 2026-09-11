# Project conventions

This file is read automatically at the start of every Claude Code session in this
repo. Keep it accurate — outdated conventions here are worse than none.

## Stack

- **Monorepo**: pnpm workspaces (`pnpm-workspace.yaml`). Never use `npm` or `yarn`
  inside a package — always `pnpm`.
- **Frontend**: Astro (islands architecture) + Tailwind CSS v4, deployed as a
  Cloudflare Worker via `@astrojs/cloudflare`.
- **API**: Cloudflare Workers, TypeScript, `wrangler` for local dev/deploy.
- **Interactive UI**: React islands for anything that needs real client state or
  routing (dashboards, editors) — see "Astro vs React islands" below.
- **Infra as code**: Terraform for Cloudflare resources (D1, KV, R2, Durable
  Objects, Zero Trust Access apps/policies), under `/infra`.
- **Data residency**: storage defaults to the EU for this template — see
  "Storage defaults to EU" in `infra/README.md` before adding a D1
  database, R2 bucket, KV namespace, or Durable Object.

## Package manager & scripts

- Root scripts run through pnpm workspace filters, e.g.
  `pnpm --filter @app/web dev`, `pnpm --filter @app/api dev`.
- Never run `npm install` anywhere in this repo — it will create a conflicting
  `package-lock.json` alongside `pnpm-lock.yaml`. If you see one, delete it.
- Lockfile changes are real changes — don't run `pnpm install` speculatively;
  only when a dependency was actually added/changed.

## Styling: Tailwind CSS v4

- Config is **CSS-first** — there is no `tailwind.config.js`. All design tokens
  (colors, spacing, breakpoints, fonts) live in `@theme` blocks inside
  `src/styles/global.css`. Don't create a JS/TS Tailwind config file.
- Import Tailwind once, in the base layout only:
  `src/layouts/BaseLayout.astro` imports `../styles/global.css`. Don't
  re-import it per-page.
- Astro is set up with the official `@tailwindcss/vite` plugin
  (`vite.plugins` in `astro.config.mjs`) — **never** add `@astrojs/tailwind`,
  it's the deprecated v3 integration and will conflict.
- Scoped `<style>` blocks inside `.astro` files that use `@apply` need
  `@reference "tailwindcss";` at the top of the block, or the build won't
  resolve the tokens.
- Prefer utility classes directly in markup over `@apply` — only reach for
  `@apply` when the same utility combo repeats 3+ times in one component.
- Custom tokens go in `@theme` using semantic names tied to the design
  (e.g. `--color-brand-500`), not raw hex values scattered through markup.

## Astro vs React islands

Default to plain Astro components (zero JS shipped). Only reach for a React
island when the component genuinely needs client-side state, effects, or
interactivity Astro can't express declaratively.

- `client:visible` — default choice for interactive-but-not-critical UI
  (below the fold, non-blocking).
- `client:load` — only for above-the-fold interactivity that must be ready
  immediately (e.g. a login form).
- `client:only="react"` — for a genuinely SPA-like sub-app (e.g. an invoice
  editor with heavy client state) that shouldn't be SSR'd at all.
- Don't wrap a whole page in a React island just because one widget on it is
  interactive — isolate the island to the smallest component that needs it.

## Cloudflare Workers / Wrangler

- Local dev for anything touching bindings (KV, D1, R2, Durable Objects) must
  use `wrangler dev`, not the plain Astro/Vite dev server — bindings aren't
  available there.
- Bindings are declared in `wrangler.jsonc`, not `wrangler.toml` (jsonc is the
  current default format — don't create a `.toml` file).
- Secrets are set via `wrangler secret put`, never committed, never placed in
  `.dev.vars` if the repo is public.
- Cloudflare resources for this project (D1 databases, KV namespaces, R2
  buckets, Zero Trust Access apps/policies, etc.) go through Terraform in
  `/infra`, not created ad hoc via the dashboard, API, or
  `wrangler d1 create`/`wrangler kv namespace create`/etc. — so changes are
  reviewable and reproducible.
- This includes bindings a framework enables automatically, not just ones
  you declare yourself — e.g. `@astrojs/cloudflare` auto-enables Astro's
  KV-backed sessions and Cloudflare Images at build time regardless of
  whether the app uses them. If a `wrangler deploy` log ever shows
  `Experimental: The following bindings need to be provisioned`, that's
  the signal to add a Terraform resource for it (see "KV session binding →
  wrangler.jsonc wiring" in `infra/README.md`) instead of letting wrangler
  auto-provision it — an auto-provisioned resource is untracked and
  re-creating it on the next deploy fails.
- New storage resources default to EU jurisdiction — D1 and R2 via
  `var.storage_jurisdiction` in `main.tf` (Terraform-native), KV via a
  manual `wrangler kv namespace create --jurisdiction eu` + `terraform
  import` (no Terraform-native support), Durable Objects via
  `.jurisdiction("eu")` at the call site in application code (no
  infra-level setting exists). See "Storage defaults to EU" in
  `infra/README.md`.
- `terraform apply` cannot be run from a Claude Code cloud/remote session
  (provider plugin install needs GitHub API access this environment
  restricts) — it must run from CI or a local/devcontainer session. See
  `infra/README.md`.

## TypeScript

- Strict mode is on. Don't add `any` to silence an error — fix the type or
  ask before widening it.
- Shared types between the Worker API and the Astro frontend live in a
  `packages/shared-types` workspace package — don't duplicate interface
  definitions across `apps/web` and `apps/api`.

## Testing

- **Default to TDD (red → green → refactor) for new features and bug fixes**,
  not just when asked — use the `tdd` skill. Agree the seams under test with
  the user before writing tests; don't write tests against unconfirmed seams.
- Two separate Vitest configs, because Worker logic and Astro components need
  different runtimes:
  - `*.worker.test.ts` — runs inside the real Workers runtime (workerd via
    Miniflare, `@cloudflare/vitest-pool-workers`), config in
    `vitest.worker.config.ts`. Use for API routes, bindings, anything that
    needs the actual Workers environment. Don't mock bindings — test against
    the real runtime this pool gives you.
  - Every other `*.test.ts` — runs under Node via `vitest.astro.config.ts`,
    which uses the Astro Container API (`astro/container`) to render
    `.astro` components. This config intentionally skips `astro.config.mjs`
    (`configFile: false`), since loading the `@astrojs/cloudflare` adapter
    crashes under plain Vitest — don't remove that flag to "fix" a missing
    adapter feature in a component test; the adapter isn't meant to be
    reachable there.
- Run everything: `pnpm test`. Run one pool: `pnpm test:worker` /
  `pnpm test:astro`.
- CI (`.github/workflows/main.yml`) runs `pnpm test` before `pnpm build` on
  every push to main — a failing test blocks deploy.
- The deploy and Terraform jobs are gated behind a `check-project-name` job
  that reads `package.json`'s `name` field: while it's still the placeholder
  `astro-workers-template`, both jobs are skipped (not failed). Run the
  `init-template` skill to clear the gate before CI will actually deploy.

## Skills

- This repo ships with a pinned skill set in `skills-lock.json`. Run
  `npx skills experimental_install --yes` after cloning (the devcontainer's
  `post-create.sh` already does this).
- If a task needs a capability not covered by an installed skill, say so
  rather than improvising — I'd rather add the skill than get inconsistent
  one-off behavior.

## What NOT to do

- Don't add `@astrojs/tailwind` (deprecated, v3-only).
- Don't create `tailwind.config.js` — v4 config is CSS-only.
- Don't run bare `npm`/`yarn` commands in a pnpm workspace.
- Don't create Cloudflare resources (Access apps/policies, D1/KV/R2/etc.)
  outside Terraform — including letting wrangler auto-provision a binding a
  framework enables by default instead of provisioning it in Terraform.
- Don't widen TypeScript types to `any` to make an error go away.
- Don't hydrate a whole page as a React island for one interactive widget.
- Don't skip TDD for new features/fixes without asking first.
- Don't mock Workers bindings in `*.worker.test.ts` — that pool runs against
  the real Workers runtime specifically so you don't have to.

## Open questions to confirm before big changes

- New Worker bindings (D1, KV, R2, Durable Objects) — the *mechanism* is
  settled (Terraform resource in `/infra` + CI wires the generated ID into
  `wrangler.jsonc`, see "Cloudflare Workers / Wrangler" above), but still
  confirm the binding *name* before adding, so `wrangler.jsonc` stays
  consistent across services.
- New shared UI components — confirm whether they belong in a
  `packages/ui` workspace package or stay local to one app.

## Development

When starting the dev server, use background mode:

```
astro dev --background
```

Manage the background server with `astro dev stop`, `astro dev status`, and `astro dev logs`.

## Documentation

Full documentation: https://docs.astro.build

Consult these guides before working on related tasks:

- [Adding pages, dynamic routes, or middleware](https://docs.astro.build/en/guides/routing/)
- [Working with Astro components](https://docs.astro.build/en/basics/astro-components/)
- [Using React, Vue, Svelte, or other framework components](https://docs.astro.build/en/guides/framework-components/)
- [Adding or managing content](https://docs.astro.build/en/guides/content-collections/)
- [Adding styles or using Tailwind](https://docs.astro.build/en/guides/styling/)
- [Supporting multiple languages](https://docs.astro.build/en/guides/internationalization/)

# UI Design Rules for Coding Agents

Look at UI.md for Design Rules.
