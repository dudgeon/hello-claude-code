# /meta — Builder's Workspace

Everything in this folder is about *building* the hello-claude-code project.
It is not shipped as part of the user-facing experience (though the repo itself is the product).

## What goes here

| Folder | Purpose |
|---|---|
| `decisions/` | Architecture Decision Records (ADRs) — numbered, append-only |
| `research/` | R&D spikes, experiments, and findings |
| `design/` | User journey maps, wireframes, interaction designs |
| `backlog.md` | Living list of work items and priorities |

## Builder mode setup

The root `CLAUDE.md` is the user-facing product (the greeter/instructor).
To work as a builder without triggering the user experience:

```sh
touch .builder-mode
```

That's it. A SessionStart hook detects the flag file and injects the builder
context from `.claude/builder-context.md`. All builder instructions are
committed to the repo — nothing is hidden from git. The only gitignored
artifact is the zero-content `.builder-mode` flag itself.

**To test the user experience:** `rm .builder-mode` and start a new session.

See [ADR 003](decisions/003-builder-mode-via-hook.md) for the full rationale.

## Conventions

- **ADRs** are numbered sequentially (`001-title.md`, `002-title.md`).
  Once written they are not edited — supersede with a new ADR instead.
- **Research** files are named by topic (`web-preview-rendering.md`, `surface-capabilities.md`).
- Everything is markdown so Claude Code can read/write it natively.
