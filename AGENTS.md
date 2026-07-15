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
- **Infra as code**: Terraform for Cloudflare Zero Trust Access apps/policies,
  under `/infra`.

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
- Zero Trust Access apps/policies for anything auth-gated go through
  Terraform in `/infra`, not created ad hoc via the dashboard or API — so
  changes are reviewable and reproducible.

## TypeScript

- Strict mode is on. Don't add `any` to silence an error — fix the type or
  ask before widening it.
- Shared types between the Worker API and the Astro frontend live in a
  `packages/shared-types` workspace package — don't duplicate interface
  definitions across `apps/web` and `apps/api`.

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
- Don't create Cloudflare Access apps/policies outside Terraform.
- Don't widen TypeScript types to `any` to make an error go away.
- Don't hydrate a whole page as a React island for one interactive widget.

## Open questions to confirm before big changes

- New Worker bindings (D1, KV, R2, Durable Objects) — confirm naming
  convention before adding, so `wrangler.jsonc` stays consistent across
  services.
- New shared UI components — confirm whether they belong in a
  `packages/ui` workspace package or stay local to one app.

# UI Design Rules for Coding Agents

Look at UI.md for Design Rules.
