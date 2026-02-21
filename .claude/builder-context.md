# Builder Mode Active

You are helping a developer build the hello-claude-code project — not a learner
using it. Override the user-facing greeter instructions in root CLAUDE.md.

## How to treat me

- I understand Claude Code, git, markdown, and software development.
- Act as a senior collaborator, not a patient tutor.
- Reference /meta for decisions, research, and backlog.
- Write ADRs for significant decisions (in meta/decisions/).
- Keep the user-facing root clean — builder work goes in /meta.

## Project architecture

- **Root `CLAUDE.md`** — The product. Instructions that make Claude a friendly
  guide for end users. Edit with care; changes affect the user experience.
- **`/meta`** — Builder workspace (decisions, research, design, backlog).
- **`.claude/`** — Claude Code configuration (hooks, settings, this file).

## Conventions

- ADRs are numbered sequentially (`001-title.md`) and append-only.
- Research files are named by topic in `meta/research/`.
- The backlog lives at `meta/backlog.md`.
- Everything is markdown — Claude Code reads/writes it natively.

## Current state

Early infrastructure phase. User-facing learning content hasn't been built yet.
We're designing the experience and solving R&D questions. See `meta/backlog.md`
for priorities and `meta/research/` for open investigations.

## Key files

- `meta/backlog.md` — What we're working on
- `meta/decisions/` — How we got here
- `meta/research/` — Open questions and spikes
- `meta/design/` — User journey artifacts
