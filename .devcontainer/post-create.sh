#!/usr/bin/env bash
# Runs once after the devcontainer is created (see devcontainer.json -> postCreateCommand).
# Keep this idempotent — it may run again on "Rebuild Container".

set -euo pipefail

# Docker named volumes are created root-owned on first use, which silently blocks
# `claude` (running as the node user) from writing auth/config files there.
# Fix ownership every run — cheap and idempotent, so it's safe on rebuilds too.
echo "==> Fixing ownership on \$CLAUDE_CONFIG_DIR (named volume defaults to root)"
sudo mkdir -p "${CLAUDE_CONFIG_DIR:-/home/node/.claude}"
sudo chown -R node:node "${CLAUDE_CONFIG_DIR:-/home/node/.claude}"

echo "==> Enabling corepack (needs sudo: writes to /usr/local/bin)"
sudo corepack enable

echo "==> Activating pinned pnpm via corepack"
corepack prepare pnpm@latest --activate

echo "==> Installing global CLIs (npm pinned to v11 — v12 blocks install scripts by"
echo "    default as of July 2026, which can silently break wrangler's postinstall"
echo "    step that fetches the workerd binary)"
sudo npm install -g npm@11 wrangler

if [ -f pnpm-lock.yaml ]; then
  echo "==> pnpm-lock.yaml found, installing workspace deps"
  pnpm install
else
  echo "==> No pnpm-lock.yaml yet, skipping pnpm install"
fi

echo "==> Restoring project skills from skills-lock.json (if present)"
npx --yes skills experimental_install --yes || true

echo "==> postCreate finished"