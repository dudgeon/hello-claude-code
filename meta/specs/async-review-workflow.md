---
status: unread
criticality: review
date: 2026-02-21
summary: Mini spec for async document review workflow between Claude and builder
---

# Spec: Async Review Workflow

## Problem

Claude generates documents faster than the builder can read them. Without a
system, work products pile up unreviewed, decisions drift from builder intent,
and feedback gets lost.

## Solution

A lightweight async review loop with three components: **frontmatter** for
status tracking, a **reading list** for prioritization, and **CriticMarkup**
for inline feedback — all processed by two skills.

## Components

### 1. Document frontmatter

Every document in `/meta` carries YAML frontmatter:

```yaml
---
status: unread | read | reviewed | accepted
criticality: fyi | review | critical
date: YYYY-MM-DD
summary: One-line description
---
```

**Status lifecycle:** `unread` → `read` → `reviewed` → `accepted`

- `unread` — Claude created or substantially edited; builder hasn't seen it
- `read` — Builder has read it (no feedback needed, or feedback pending)
- `reviewed` — Builder left CriticMarkup feedback; Claude has processed it
- `accepted` — Feedback loop closed; document is stable

**Criticality tiers:**

- `critical` — Blocks downstream work. Read before next work session.
- `review` — Needs builder input before dependent work proceeds.
- `fyi` — Informational. Read when convenient.

### 2. Reading list (`meta/reading-list.md`)

A single prioritized queue. Ordered: critical → review → fyi, then by logical
reading sequence within each tier (prerequisites before dependents).

Maintained by Claude. Rebuilt via `/update-reading-list`.

### 3. CriticMarkup feedback

The builder annotates documents inline using CriticMarkup:

| Syntax | Meaning | Example |
|--------|---------|---------|
| `{++text++}` | Add text | `{++Also consider X++}` |
| `{--text--}` | Delete text | `{--This is wrong--}` |
| `{~~old~>new~~}` | Replace | `{~~three~>four~~}` |
| `{>>comment<<}` | Comment | `{>>Why this approach?<<}` |
| `{==text==}{>>comment<<}` | Highlight + comment | `{==this claim==}{>>needs citation<<}` |

## Workflow

```
Claude creates/edits document
  → Sets frontmatter: status=unread, criticality=X
  → Updates reading list
  → Continues working (non-blocked items)

Builder checks reading list
  → Reads documents in priority order
  → Leaves CriticMarkup inline for feedback
  → Says "/review-feedback" (optionally with file path)

Claude processes feedback (/review-feedback)
  → Applies edits ({++ --  ~~})
  → Extracts comments ({>> <<}) as takeaways
  → Identifies downstream impacts (backlog, skills, other docs)
  → Sets status=reviewed
  → Updates reading list
  → Reports summary to builder

Builder accepts or iterates
  → If satisfied: status moves to accepted
  → If not: another round of CriticMarkup
```

## Skills

### `/update-reading-list`

**Trigger:** After creating/editing documents, or on demand.
**Action:** Scans all `/meta` frontmatter, rebuilds `meta/reading-list.md`.
**Output:** Updated reading list + change summary.

### `/review-feedback [path]`

**Trigger:** Builder says "/review-feedback" after annotating documents.
**Action:**
1. Apply CriticMarkup edits to document text
2. Extract comments as takeaways
3. Assess downstream impacts (backlog, skills, conventions, CLAUDE.md)
4. Update frontmatter to `reviewed`
5. Rebuild reading list

**Output:** Summary with edit count, takeaways, and recommended downstream
changes (asks before modifying other files).

## Design principles

- **Builder is the bottleneck, not Claude.** The system respects builder
  attention. Critical items surface first. FYI items don't nag.
- **Feedback is inline, not out-of-band.** CriticMarkup lives in the document
  itself — no separate feedback files, no chat-only feedback that gets lost.
- **Processing is explicit.** Claude doesn't auto-process CriticMarkup on read.
  The builder triggers `/review-feedback` when they're done annotating.
- **Downstream impacts are surfaced, not auto-applied.** Claude identifies what
  else needs to change but asks before touching other files.

## Open questions

- Should there be a `/mark-read [path]` convenience skill, or is manual
  frontmatter editing sufficient?
- Should the reading list include estimated reading time?
- Should `/review-feedback` auto-commit after processing, or leave that to the
  builder?
