---
status: unread
criticality: critical
date: 2026-02-22
summary: Desktop app as primary target, CLI + projection as fallback — resolves the surface question
---

# ADR 004: Platform Target — Desktop Primary, CLI + Projection Backup

## Status

Accepted

## Context

We needed to decide which Claude Code surface to target as primary. The
research in `meta/research/interaction-model.md` and
`meta/research/surface-capabilities.md` identified three candidates:

| Surface | Visual capability | HTML feedback loop | Markdown quality |
|---|---|---|---|
| **Desktop app** | Embedded browser, screenshots, DOM inspection | Claude can observe (not receive events) | Good |
| **VS Code extension** | Same as CLI (it's the CLI in a terminal panel) | None | Good (VS Code renders) |
| **CLI (terminal)** | None — write-only | None | Poor (known bugs) |
| **Web (claude.ai/code)** | Sandboxed | None | Good |

Key constraints established through R&D:

1. **No programmatic channel exists from rendered HTML back to Claude Code.**
   The browser and Claude run in separate processes with no bridge.
2. **A local server with write endpoints** could close the loop, but adds
   infrastructure complexity inappropriate for beginner users.
3. **The VS Code extension is effectively the CLI** — same tools, same
   constraints. It doesn't use VS Code's webview API.
4. **Browser plugins and MCP servers** cannot be assumed available for our
   target users.
5. **The Desktop app is qualitatively different** — its embedded browser
   makes visuals seamless and its screenshot capability lets Claude observe
   rendered output.

## Decision

**Primary target: Claude Desktop app.**

- Design lessons assuming the embedded browser preview is available.
- Use Desktop's screenshot capability for Claude to verify visual output.
- Explore `.claude/launch.json` pre-configuration so preview "just works."

**Backup: CLI + projection pattern.**

- Every visual must have a text fallback (markdown or plain text).
- HTML is a write-only "projection" — informational, never interactive.
- All user input flows through the chat. The visual provides context and
  richness; the chat provides the interaction channel.
- CLI markdown rendering is buggy (tables, bold, non-ASCII), so text
  fallbacks should be defensive — prefer lists and headers, avoid complex
  tables.

**When a feature only works on one surface:** Flag it during development so
we can decide whether to build a fallback, skip it for CLI users, or find
an alternative approach. This is a per-feature conversation, not a blanket
policy.

## Consequences

- **Lesson design starts with Desktop.** The richest version of each lesson
  assumes embedded preview. CLI gets a graceful degradation, not a separate
  implementation.
- **Visuals are projections, not interfaces.** HTML shows things; chat
  handles all interaction. This principle applies to both surfaces but is
  especially important for CLI where there's zero visual feedback channel.
- **Surface detection matters.** Claude should know which surface it's
  running on so it can choose the right rendering path. How to detect this
  is an open implementation question.
- **We accept a tiered experience.** Desktop users get the full experience.
  CLI users get a functional but visually degraded version. We should be
  honest about this in onboarding.
- **Future-proof.** As Desktop capabilities evolve (richer screenshot loop,
  potential event bridges), we're positioned to adopt them. The projection
  pattern means CLI won't break when Desktop gets new features.

## What this replaces

Resolves open question #1 in `meta/research/interaction-model.md` ("Should
we declare Desktop app as the recommended surface?"). Answer: yes.

Supersedes the "Later" backlog items for per-surface testing — surface
testing is now part of ongoing development, not a deferred pass.
