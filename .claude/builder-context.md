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

## Document frontmatter

All documents in `/meta` (decisions, research, design) MUST include YAML
frontmatter with review metadata:

```yaml
---
status: unread | read | reviewed | accepted
criticality: fyi | review | critical
date: YYYY-MM-DD
summary: One-line description of what this document covers
---
```

- **status**: Default `unread`. Set to `read` when the builder has seen it,
  `reviewed` when they've left feedback, `accepted` when feedback is resolved.
- **criticality**: `fyi` = informational, read when convenient. `review` =
  needs builder input before dependent work proceeds. `critical` = blocking;
  read before next session.
- When you create or substantially edit a document, always set/update the
  frontmatter and update `meta/reading-list.md`.

## Reading list

Maintain `meta/reading-list.md` as a prioritized queue of documents the builder
needs to review. Order by: critical first, then review, then fyi — and within
each tier, by logical reading sequence (prerequisites before dependents).

Update this list whenever you create, substantially edit, or learn that a
document has been reviewed. Use the `/update-reading-list` skill to rebuild
the list from current frontmatter state.

## CriticMarkup feedback

The builder reviews documents using CriticMarkup notation:

- `{++addition++}` — text to add
- `{--deletion--}` — text to delete
- `{~~old~>new~~}` — substitution
- `{>>comment<<}` — comment/annotation
- `{==highlight==}{>>comment<<}` — highlight with comment

When you encounter CriticMarkup in any file, use the `/review-feedback` skill
to process it: apply corrections, extract takeaways, and identify required
changes to other files, the roadmap, or conventions.

## Current state

Early infrastructure phase. User-facing learning content hasn't been built yet.
We're designing the experience and solving R&D questions. See `meta/backlog.md`
for priorities and `meta/research/` for open investigations.

## Key files

- `meta/backlog.md` — What we're working on
- `meta/reading-list.md` — Documents queued for builder review
- `meta/decisions/` — How we got here
- `meta/research/` — Open questions and spikes
- `meta/design/` — User journey artifacts
