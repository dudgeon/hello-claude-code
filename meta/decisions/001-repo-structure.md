---
status: unread
criticality: fyi
date: 2026-02-21
summary: Established /meta for builder content, root for user-facing content
---

# ADR 001 — Repo Structure

**Status:** Accepted
**Date:** 2026-02-21

## Context

This repo *is* the product. A new user will clone or open it and learn Claude Code
by working inside it. At the same time, we (the builders) need a place to plan,
research, and make decisions without cluttering the user-facing tree.

## Decision

- `/meta` holds all builder-oriented content (decisions, research, design, backlog).
- The repo root is user-facing: `README.md`, `CLAUDE.md`, and the learning content itself.
- Content that the user interacts with lives at the top level or in clearly named
  directories (structure TBD as we design the user journey).

## Consequences

- Root stays clean and approachable for a first-time GitHub visitor.
- We can iterate on builder docs freely without touching the user experience.
- `CLAUDE.md` at the root gives Claude Code project context for anyone working in the repo.
