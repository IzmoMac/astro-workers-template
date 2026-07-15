---
name: init-template
description: Initialize this Astro + Cloudflare Workers template for a new project by renaming it away from the placeholder "astro-workers-template" name. Use when the user says they're starting a new project from this template, wants to rename the template, or asks to "init"/"initialize" the repo.
---

# Initialize Template

This repo starts life as a clone of a generic template. Before real work begins,
the placeholder project name needs to be replaced everywhere it's used as an
identifier (npm package name, deployed Cloudflare Worker name, ignore-file
entry), not just where it appears in prose.

## 1. Find the current placeholder name

Don't hardcode `astro-workers-template` — read it from `package.json`'s `name`
field so this skill still works correctly if it's ever run again on a repo
that was already renamed once (e.g. copied to spin up a second project).

```
CURRENT_NAME=$(node -p "require('./package.json').name")
```

Then find every file that references it:

```
grep -rIl "$CURRENT_NAME" . --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist --exclude-dir=.wrangler
```

Expect to see at least `package.json` and `wrangler.jsonc`. Report any
additional matches to the user before proceeding — don't silently skip them.

## 2. Ask for the new name

Always ask interactively — never infer the name from context or take it as a
pre-supplied argument without confirming.

Ask what the new project should be called. Once you have an answer, derive:

- **slug**: lowercase, digits and hyphens only, no leading/trailing hyphen,
  no consecutive hyphens (e.g. `my-cool-app`). This is what goes in
  `package.json`'s `name` and `wrangler.jsonc`'s `name`. Cloudflare Worker
  names and npm package names both require this shape — if the user's answer
  doesn't already fit it, normalize it (`My Cool App` → `my-cool-app`) and
  confirm the derived slug with them before writing anything.
- **title**: a human-readable version for display text (e.g. `My Cool App`).

## 3. Apply the rename

Replace `CURRENT_NAME` with the new slug in:

- `package.json` — the `"name"` field.
- `wrangler.jsonc` — the `"name"` field. This is the actual Worker name
  Cloudflare deploys under, so it determines the `*.workers.dev` URL. Flag
  this to the user: if a Worker was already deployed under the old name,
  renaming here does not rename or delete that existing Worker — it starts
  a **new** one on the next `wrangler deploy`. If they need the old one
  removed, that's a separate, explicit action (don't do it as part of this
  skill).
- Any other file the grep in step 1 turned up.

Also update `src/layouts/Layout.astro`'s `<title>` tag (currently
`Astro Basics`, the stock Astro-starter placeholder) to the new **title**.

Use `Edit`, not a blind find-and-replace script — review each match, since a
generic slug could theoretically collide with unrelated text.

## 4. Verify

- Re-run the grep from step 1 to confirm no leftover occurrences of the old
  name remain (outside of `.git` history, which is expected and fine).
- Run `pnpm astro check` (or equivalent) if available to make sure nothing
  broke.
- Show the user a summary of what changed (`git diff --stat` is enough) and
  stop there — do not commit on their behalf.
