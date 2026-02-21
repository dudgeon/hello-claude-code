---
status: unread
criticality: review
date: 2026-02-21
summary: Capability matrix across VS Code, Desktop, and Terminal surfaces
---

# R&D: Surface Capabilities Matrix

## Surfaces where Claude Code runs

Users will come to this project from different Claude Code surfaces.
We need to understand what each can do so we design content that degrades
gracefully (or pick a primary surface and be explicit about it).

## Capability matrix (to be filled in via testing)

| Capability | VS Code Ext | Desktop App | Terminal |
|---|---|---|---|
| Markdown rendering | ? | ? | ? |
| HTML preview | ? | ? | N/A |
| File system access | Yes | Yes | Yes |
| Open URL in browser | ? | ? | Yes |
| Skills / slash commands | Yes | ? | Yes |
| CLAUDE.md loaded | Yes | Yes | Yes |
| Inline images | ? | ? | N/A |
| MCP servers | Yes | Yes | Yes |

## Key questions

1. **What is our primary surface?**
   We should pick one and optimize for it, then ensure others are usable.

2. **What's the minimum viable experience on terminal-only?**
   If someone uses Claude Code in a raw terminal, what do they get?

3. **Can we detect the surface at runtime?**
   Could CLAUDE.md or a skill sniff the environment and adapt?

## Next steps

- [ ] Audit each surface's documentation for rendering capabilities
- [ ] Test each capability cell above empirically
- [ ] Write ADR on primary surface choice
