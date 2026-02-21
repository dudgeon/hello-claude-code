---
name: review-feedback
description: Process CriticMarkup feedback from reviewed documents
---

Process CriticMarkup feedback left by the builder. If `$ARGUMENTS` specifies
a file path, process that file. Otherwise, scan all files in `meta/` for
CriticMarkup notation.

## CriticMarkup syntax

- `{++addition++}` — insert this text
- `{--deletion--}` — remove this text
- `{~~old~>new~~}` — replace old with new
- `{>>comment<<}` — annotation / feedback (do not apply as an edit; extract as a takeaway)
- `{==highlight==}{>>comment<<}` — highlighted text with a comment

## Processing steps

### 1. Apply edits

For each CriticMarkup edit (`{++ ++}`, `{-- --}`, `{~~ ~>  ~~}`), apply the
change to the document and remove the markup. Leave the clean text in place.

### 2. Extract takeaways

For each comment (`{>> <<}`), extract it as a takeaway. Compile all takeaways
into a summary, grouped by document.

### 3. Identify downstream impacts

Review each takeaway and determine if it requires changes to:
- **Other documents** — e.g., a correction in one doc that contradicts another
- **The backlog** (`meta/backlog.md`) — new items, reprioritizations, or removals
- **Skills** (`.claude/skills/`) — behavior changes or new skills needed
- **Builder context** (`.claude/builder-context.md`) — convention changes
- **Root CLAUDE.md** — user-facing changes

List each required change explicitly. Ask the builder before making changes
to files other than the one being reviewed.

### 4. Update frontmatter

Set the reviewed document's frontmatter `status` to `reviewed`.

### 5. Update reading list

After processing, run the equivalent of `/update-reading-list` to reflect the
new status.

### 6. Report

Present a summary:
- Edits applied (count and nature)
- Takeaways extracted
- Downstream changes identified (with recommendations)
- Reading list updates
