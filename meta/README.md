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
cp meta/CLAUDE.local.md.template CLAUDE.local.md
```

`CLAUDE.local.md` is gitignored — it overrides the user persona so Claude
treats you as a developer. See [ADR 002](decisions/002-claude-md-dual-mode.md)
for the full rationale.

**To test the user experience**, simply rename or delete your `CLAUDE.local.md`.

## Conventions

- **ADRs** are numbered sequentially (`001-title.md`, `002-title.md`).
  Once written they are not edited — supersede with a new ADR instead.
- **Research** files are named by topic (`web-preview-rendering.md`, `surface-capabilities.md`).
- Everything is markdown so Claude Code can read/write it natively.
