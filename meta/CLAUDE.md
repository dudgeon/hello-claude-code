# Builder Context — /meta

You are helping a developer build the hello-claude-code project.

This directory is the builder's workspace. Everything here is about designing,
planning, and constructing the user-facing learning experience — it is not part
of the experience itself.

## How this project works

- The root `CLAUDE.md` is the user-facing product — it instructs Claude to be
  a guide for learners. Do not edit it casually; changes there affect the UX.
- `/meta/decisions/` has Architecture Decision Records. They are append-only —
  never edit an existing ADR, write a new one to supersede it.
- `/meta/research/` has R&D docs for open questions.
- `/meta/design/` is for user journey design artifacts.
- `/meta/backlog.md` is the living priority list.

## Conventions

- ADRs are numbered sequentially: `001-title.md`, `002-title.md`.
- Research files are named by topic: `web-preview-rendering.md`.
- When making a decision that affects project structure or approach, write an ADR.
- Keep the root directory clean — user-facing content only.

## Current state

The project is in early infrastructure phase. The user-facing content hasn't
been built yet. We're designing the learning experience and solving technical
R&D questions (see research/).
