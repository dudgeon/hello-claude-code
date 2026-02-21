---
status: unread
criticality: fyi
date: 2026-02-21
summary: Replaced CLAUDE.local.md with SessionStart hook + .builder-mode flag
---

# ADR 003 — Builder Mode via SessionStart Hook

**Status:** Accepted (supersedes ADR 002)
**Date:** 2026-02-21

## Context

ADR 002 introduced the dual-mode strategy using `CLAUDE.local.md` (gitignored)
to overlay builder context on top of the user-facing root `CLAUDE.md`.

The problem: `CLAUDE.local.md` carries all the builder instructions, and because
it's gitignored, that content doesn't travel with the repo. When someone forks
the project (e.g., for a work-specific version), they lose the builder context
entirely. The content that matters most for collaboration is the content that's
hidden from git.

## Decision

Replace the `CLAUDE.local.md` pattern with a **SessionStart hook + flag file**
pattern:

### What's committed to git (travels with forks)

- `.claude/builder-context.md` — All builder instructions, project context,
  conventions. This is the substantive content that was previously in the
  gitignored template.
- `.claude/hooks/inject-builder-context.sh` — A SessionStart hook that checks
  for the flag file and injects builder context if present.
- `.claude/settings.json` — Registers the hook so it runs on session start.

### What's gitignored (the toggle)

- `.builder-mode` — A zero-content flag file. Its presence activates builder
  mode. It contains no information — it's purely a signal.

### How it works

1. User clones the repo, opens Claude Code → root `CLAUDE.md` loads, Claude is
   the friendly guide. No `.builder-mode` file exists, hook outputs nothing.

2. Builder clones the repo, runs `touch .builder-mode` → hook detects the flag,
   injects `.claude/builder-context.md` into the session context. Claude treats
   them as a developer.

3. Builder wants to test the user experience → `rm .builder-mode`, start new
   session. Back to greeter mode.

## What changed from ADR 002

- `CLAUDE.local.md` is no longer used (removed from `.gitignore`).
- `meta/CLAUDE.local.md.template` is removed.
- Builder instructions moved from the template to `.claude/builder-context.md`.
- `meta/CLAUDE.md` remains — it provides additional context when Claude works
  in the `/meta` directory specifically.

## Consequences

- All builder content is committed and travels with forks.
- The only gitignored artifact is a zero-content flag file.
- Collaboration is fully supported — new builders just `touch .builder-mode`.
- The toggle mechanism is simple and discoverable.
- We depend on the SessionStart hook feature, which is well-supported but means
  the builder must approve the hook on first run.
