@AGENTS.md

## Claude Code-specific

Everything above (imported from AGENTS.md) is the shared, cross-tool source of
truth. This section is only for behavior that's genuinely Claude Code-specific —
don't duplicate anything already covered above.

- Skills are pinned via `skills-lock.json` (installed with `npx skills`, which is
  itself agent-agnostic — see "Skills" below). No Claude-only skill setup needed.
- If a task would benefit from a dedicated subagent (e.g. an isolated code-review
  pass) or a project hook, define it under `.claude/agents/` or `.claude/hooks/`
  rather than improvising inline — ask first if none exists yet for the need.

## Skills (cross-tool, not Claude-only)

This repo's skills are managed with `npx skills` (vercel-labs/skills), which
supports 70+ agents including Claude Code, Codex, Cursor, and OpenCode via
`--agent <name>`. The pinned set in `skills-lock.json` isn't Claude-specific —
whichever agent you're running, `npx skills experimental_install --yes` restores
the same skill set for that agent's directory convention.
