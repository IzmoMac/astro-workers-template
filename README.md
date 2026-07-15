# Astro Starter Kit: Basics

```sh
pnpm create astro@latest -- --template basics
```

> 🧑‍🚀 **Seasoned astronaut?** Delete this file. Have fun!

## 🚀 Project Structure

Inside of your Astro project, you'll see the following folders and files:

```text
/
├── public/
│   └── favicon.svg
├── src
│   ├── assets
│   │   └── astro.svg
│   ├── components
│   │   └── Welcome.astro
│   ├── layouts
│   │   └── Layout.astro
│   └── pages
│       └── index.astro
└── package.json
```

To learn more about the folder structure of an Astro project, refer to [our guide on project structure](https://docs.astro.build/en/basics/project-structure/).

## 🧞 Commands

All commands are run from the root of the project, from a terminal:

| Command                   | Action                                           |
| :------------------------ | :----------------------------------------------- |
| `pnpm install`             | Installs dependencies                            |
| `pnpm dev`             | Starts local dev server at `localhost:4321`      |
| `pnpm build`           | Build your production site to `./dist/`          |
| `pnpm preview`         | Preview your build locally, before deploying     |
| `pnpm astro ...`       | Run CLI commands like `astro add`, `astro check` |
| `pnpm astro -- --help` | Get help using the Astro CLI                     |
| `pnpm test`            | Run all tests (Worker + Astro component)         |
| `pnpm test:worker`     | Run just `*.worker.test.ts` (real Workers runtime) |
| `pnpm test:astro`      | Run everything else (Astro component tests)      |

## 🧪 Testing

Two Vitest configs, because Worker logic and Astro components need different
runtimes:

- `*.worker.test.ts` files run inside the real Workers runtime (workerd via
  Miniflare, `@cloudflare/vitest-pool-workers`) — for API routes, bindings,
  anything that needs the actual Workers environment rather than a mock.
- Every other `*.test.ts` runs under Node, using the
  [Astro Container API](https://docs.astro.build/en/reference/container-reference/)
  to render `.astro` components in isolation.

New features and bug fixes go through TDD by default — see the `tdd` skill
(`.claude/skills/tdd`) — not just when asked. CI runs `pnpm test` before
every deploy; a failing test blocks it.

## 🚀 Deploy

Pushing to `main` builds the site and deploys it to Cloudflare Workers via
GitHub Actions (`.github/workflows/main.yml`) — no manual `wrangler deploy`
needed once it's set up. The same workflow also applies the Terraform config
in [`/infra`](./infra).

Before the first push to `main` will work, do the one-time setup in
[`infra/README.md`](./infra/README.md): create an R2 bucket for Terraform
state, and add these GitHub repo secrets:

- `CLOUDFLARE_API_TOKEN`
- `CLOUDFLARE_ACCOUNT_ID`
- `TF_STATE_BUCKET`
- `R2_ACCESS_KEY_ID`
- `R2_SECRET_ACCESS_KEY`

Once deployed, the site is live at
`https://<worker-name>.<subdomain>.workers.dev` — `<worker-name>` is the
`name` field in `wrangler.jsonc` (see the `init-template` skill to rename it).

The workflow starts with a `check-project-name` job that reads `package.json`'s
`name` field. As long as it's still the template placeholder
(`astro-workers-template`), the deploy and Terraform jobs are skipped (shown
as "skipped" in the Actions run, not failed) so a fresh clone can't
accidentally deploy under the template's name. Run the `init-template` skill
(or rename it manually in `package.json` and `wrangler.jsonc`) to clear the
gate.

## 👀 Want to learn more?

Feel free to check [our documentation](https://docs.astro.build) or jump into our [Discord server](https://astro.build/chat).
