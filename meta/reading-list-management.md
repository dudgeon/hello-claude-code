# Reading List Management

How the async review workflow keeps Claude and the builder in sync.

---

## CLAUDE.md snippet (from `.claude/builder-context.md`)

The following sections from builder context govern reading list behavior:

### Document frontmatter

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

### Reading list

Maintain `meta/reading-list.md` as a prioritized queue of documents the builder
needs to review. Order by: critical first, then review, then fyi — and within
each tier, by logical reading sequence (prerequisites before dependents).

Update this list whenever you create, substantially edit, or learn that a
document has been reviewed. Use the `/update-reading-list` skill to rebuild
the list from current frontmatter state.

### CriticMarkup feedback

The builder reviews documents using CriticMarkup notation:

- `{++addition++}` — text to add
- `{--deletion--}` — text to delete
- `{~~old~>new~~}` — substitution
- `{>>comment<<}` — comment/annotation
- `{==highlight==}{>>comment<<}` — highlight with comment

When you encounter CriticMarkup in any file, use the `/review-feedback` skill
to process it: apply corrections, extract takeaways, and identify required
changes to other files, the roadmap, or conventions.

---

## Skill: `/update-reading-list`

> Source: `.claude/skills/update-reading-list/SKILL.md`

Scan all markdown files in `meta/decisions/` and `meta/research/` for YAML
frontmatter containing `status` and `criticality` fields.

Rebuild `meta/reading-list.md` with the following structure:

1. **"Needs review"** section, subdivided by criticality tier:
   - **Critical** — documents with `criticality: critical` and `status: unread`
   - **Review** — documents with `criticality: review` and `status: unread`
   - **FYI** — documents with `criticality: fyi` and `status: unread`

2. **"Already read"** section — documents with `status: read`, `reviewed`,
   or `accepted`

Within each tier, order by logical reading sequence: prerequisites before
documents that depend on them. Use the `summary` field from frontmatter
for the description.

Each entry should be a checkbox list item linking to the document (relative
to the `meta/` directory), with the summary as a description.

Format:
```markdown
- [ ] **[Document Title](path/from/meta)** — summary text
```

For already-read items use `[x]` checkboxes.

After rebuilding, report what changed (new documents added, status changes
detected, items moved between sections).

---

## Skill: `/review-feedback`

> Source: `.claude/skills/review-feedback/SKILL.md`

Process CriticMarkup feedback left by the builder. If `$ARGUMENTS` specifies
a file path, process that file. Otherwise, scan all files in `meta/` for
CriticMarkup notation.

### Processing steps

1. **Apply edits** — For each CriticMarkup edit (`{++ ++}`, `{-- --}`,
   `{~~ ~> ~~}`), apply the change to the document and remove the markup.
   Leave the clean text in place.

2. **Extract takeaways** — For each comment (`{>> <<}`), extract it as a
   takeaway. Compile all takeaways into a summary, grouped by document.

3. **Identify downstream impacts** — Review each takeaway and determine if
   it requires changes to:
   - Other documents (corrections, contradictions)
   - The backlog (`meta/backlog.md`)
   - Skills (`.claude/skills/`)
   - Builder context (`.claude/builder-context.md`)
   - Root `CLAUDE.md`

   List each required change explicitly. Ask the builder before making
   changes to files other than the one being reviewed.

4. **Update frontmatter** — Set the reviewed document's `status` to `reviewed`.

5. **Update reading list** — Run the equivalent of `/update-reading-list`
   to reflect the new status.

6. **Report** — Present a summary: edits applied (count and nature),
   takeaways extracted, downstream changes identified (with recommendations),
   and reading list updates.

---

## How the pieces fit together

```
Claude creates/edits document
  → Sets frontmatter: status=unread, criticality=X
  → Runs /update-reading-list
  → Continues working on non-blocked items

Builder checks meta/reading-list.md
  → Reads documents in priority order
  → Leaves CriticMarkup inline for feedback
  → Says "/review-feedback" (optionally with file path)

Claude processes feedback (/review-feedback)
  → Applies edits, extracts comments as takeaways
  → Identifies downstream impacts
  → Sets status=reviewed, rebuilds reading list
  → Reports summary to builder

Builder accepts or iterates
  → If satisfied: status → accepted
  → If not: another round of CriticMarkup
```
