# ADR 002 — CLAUDE.md Dual-Mode Strategy

**Status:** Accepted
**Date:** 2026-02-21

## Context

The root `CLAUDE.md` serves two audiences with conflicting needs:

- **End users** — The people learning Claude Code. For them, CLAUDE.md *is* the
  product: a greeter, instructor, and guide. It should welcome a beginner who
  types "Hello, Claude" and orient them into the onboarding experience.

- **Builders (us)** — The people developing this repo. We need Claude to understand
  the project architecture, our conventions, and what we're working on.

These can't coexist in one file. A beginner who opens the repo and sees
"run tests with `npm test`" or "see meta/backlog.md for current priorities"
would be confused immediately.

## Decision

**Root CLAUDE.md is always the user experience.** It ships as-is and is the
first thing Claude reads when a new user opens this repo.

Builder context is layered on via mechanisms that never reach the end user:

### Layer 1: `CLAUDE.local.md` (dev overlay)

- Auto-gitignored by Claude Code — never committed, never shipped.
- Each builder creates this locally (from a template at `meta/CLAUDE.local.md.template`).
- Contains: "I am a builder. Ignore the user-facing instructions in CLAUDE.md
  and instead treat me as a developer working on this project."
- Augments (does not replace) root CLAUDE.md, but effectively overrides the
  persona/behavior for the session.

### Layer 2: `meta/CLAUDE.md` (builder context, on-demand)

- Loads automatically when Claude works with files in `/meta`.
- Contains project architecture, conventions, and builder-specific instructions.
- Checked into git — shared across the team.

### Layer 3: Future — SessionStart hook (optional enhancement)

- Could detect builder vs. user mode automatically (e.g., check if
  `CLAUDE.local.md` exists, or check for an env var).
- Could inject mode-specific context dynamically.
- Not needed for v1 — the manual `CLAUDE.local.md` approach is simple and
  sufficient.

## How it works in practice

**New user clones the repo, opens Claude Code, says "Hello, Claude":**
1. Root CLAUDE.md loads → Claude is the greeter/instructor
2. No CLAUDE.local.md exists → no dev overlay
3. Claude welcomes them and begins onboarding

**Builder clones the repo, copies the template:**
1. `cp meta/CLAUDE.local.md.template CLAUDE.local.md`
2. Root CLAUDE.md loads → user-facing instructions
3. CLAUDE.local.md loads → overrides persona to builder mode
4. Claude treats them as a developer

## Consequences

- Root CLAUDE.md can be designed purely for the user with no compromises.
- Builders get full dev context without polluting the user experience.
- The template pattern means new builders can onboard in one command.
- We can iterate on the user-facing CLAUDE.md and test it by simply
  removing/renaming our local CLAUDE.local.md.
