# R&D: Rich Visual Content via Web Preview

## The goal

Deliver rich, interactive visual content (self-contained HTML pages) that the user
sees inline while working with Claude Code. Think: diagrams, interactive
explainers, step-by-step visual walkthroughs — not just markdown.

## The challenge

Claude Code runs on multiple surfaces, each with different capabilities:

| Surface | Preview pane? | How files open | Notes |
|---|---|---|---|
| **VS Code extension** | Yes — built-in preview | Can open HTML in preview tab via `open` or VS Code commands | Most promising surface for rich content |
| **Claude Desktop app** | Unknown | Need to investigate | May have its own rendering |
| **Terminal-only** | No native preview | Would need to launch browser | Fallback to markdown? |

## Open questions

1. **How does Claude Code open a file in the preview pane?**
   - Can a tool call or bash command trigger it?
   - Is there an API/command like `code --preview file.html`?
   - Does it differ by surface?

2. **Self-contained HTML — what are the constraints?**
   - Can we use inline `<style>` and `<script>`?
   - CSP restrictions in VS Code webview?
   - Can we embed images as base64 data URIs?
   - Max file size before things get sluggish?

3. **Fallback story for terminal-only users**
   - Open in default browser via `xdg-open` / `open`?
   - Provide a markdown-only version of each visual?
   - Or just declare VS Code as the primary supported surface?

4. **Authoring workflow**
   - Should Claude Code generate these pages on-the-fly from templates?
   - Or are they static files checked into the repo?
   - Hybrid: templates in repo, Claude personalizes at runtime?

5. **Interactivity**
   - Can the HTML page communicate back to Claude Code? (Probably not.)
   - Can it read from the repo filesystem? (Probably not in webview sandbox.)
   - Implication: pages must be fully self-contained and one-directional.

## Next steps

- [ ] Spike: Create a minimal self-contained HTML page and try to open it from Claude Code in VS Code
- [ ] Spike: Try the same in Claude Desktop app
- [ ] Spike: Try `open`/`xdg-open` from terminal-only
- [ ] Document findings and write ADR on chosen approach
