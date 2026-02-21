---
name: update-reading-list
description: Rebuild the reading list from current document frontmatter
---

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
