---
status: unread
criticality: critical
date: 2026-02-22
summary: How visuals render, how user actions flow back to Claude, and what the playground plugin teaches us
---

# R&D: Interaction Model — Visuals, Feedback, and the Rendering Loop

## The questions

When Claude presents a visual (say, the intro screen showing five learning
areas), three things need to work:

1. **Rendering**: How does the visual get in front of the user?
2. **Interaction**: If the user clicks/selects something in the visual, how
   does Claude learn about it?
3. **Automation**: Can Claude handle all of this, or does the user need to
   take manual steps?

## What we learned from the Playground plugin

Anthropic's official [playground plugin](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/playground)
solves a version of this problem. Its architecture:

1. Claude generates a **self-contained HTML file** (all CSS/JS inlined, zero
   external dependencies, dark theme, system fonts).
2. Claude tells the user to run `open filename.html` — the file opens in
   their default browser.
3. The user interacts with controls (sliders, toggles, dropdowns, canvas
   drag-and-drop).
4. The page generates a **natural-language prompt** summarizing the user's
   choices (only non-default values).
5. The user **copies that prompt** and pastes it back into Claude.
6. Claude acts on the pasted prompt.

### What's reusable

- **Self-contained HTML generation** — proven pattern, works everywhere. The
  single-file constraint (no CDN, no server) is smart for reliability.
- **State-driven rendering** — single state object, all controls write to it,
  `updateAll()` triggers on every change. Clean architecture for generated pages.
- **Parameterized templates** — the plugin ships template files (design
  playground, concept map, data explorer, document critique) that Claude
  populates at runtime. This aligns exactly with our lesson kit model.
- **Dark theme + system fonts** — sensible defaults for generated content.

### What doesn't transfer

- **The copy-paste loop** — this is the critical limitation. Communication
  from rendered HTML back to Claude requires the user to manually copy a
  prompt and paste it. For a learning experience targeting beginners, this
  is too much friction. Every visual interaction would break flow.
- **Browser dependency** — `open file.html` works on macOS/Linux desktops
  but may not work in all Claude Code environments (web sandbox, containers).

## The fundamental constraint

**There is no programmatic channel from a rendered HTML page back to Claude
Code.** The HTML runs in a browser (or VS Code webview). Claude Code runs in
a terminal/agent process. They cannot talk to each other.

This means:

| Direction | Works? | How |
|---|---|---|
| Claude → Visual | Yes | Write HTML file, tell user to open it (or auto-open) |
| Visual → Claude | **No** | User must manually relay information back to chat |
| Claude → User (text) | Yes | Chat output, markdown |
| User → Claude (text) | Yes | Chat input |

## Design implications for hello-claude-code

### Principle: Visuals are projections, not interfaces

The rendered HTML should be **informational, not interactive**. It shows the
user something — a diagram, a concept map, their progress, a visual
explanation — but all *input* happens through the chat.

This is actually fine for our use case. Consider the intro flow:

**Bad design** (requires HTML→Claude feedback):
> Claude renders five clickable learning areas. User clicks one. Claude
> needs to know which one was clicked. → Requires copy-paste or polling.

**Good design** (visual is read-only, chat handles input):
> Claude renders a visual showing five learning areas with descriptions.
> In the chat, Claude asks: "Which of these interests you most? You can
> say the name or number." User types "3" or "markdown." → Claude knows.

The visual provides context and richness. The chat provides the interaction
channel. They complement each other.

### Exceptions: When interactivity is worth the friction

Some visuals might benefit from user manipulation even with the copy-paste
cost — but only when the interaction is:

1. **Hard to express in text** (e.g., spatially arranging a concept map)
2. **A one-time exploration** (not repeated every lesson)
3. **Worth the friction** for the learning value

For these cases, the playground's prompt-output pattern is viable: generate
a prompt, user copies it back. But these should be rare — special moments,
not the standard interaction model.

### The rendering question by surface

| Surface | How to open visuals | Automation |
|---|---|---|
| **VS Code** | `code --preview file.html` or VS Code webview | Claude can invoke; user approves tool use |
| **Terminal (desktop)** | `open` / `xdg-open` launches browser | Claude can invoke; user approves |
| **Terminal (remote/SSH)** | No browser available | Fallback to markdown-only |
| **claude.ai/code (web)** | No browser access from sandbox | Fallback to markdown-only |

**Implication**: Every visual must have a **text fallback**. The visual
enriches the experience but the lesson must work without it.

### Proposed interaction patterns

**Pattern 1: Illustrated explanation**
```
Claude writes HTML → opens it → explains in chat alongside
User reads both → responds in chat
```
Use for: concept diagrams, architecture views, "what happened" after a commit.

**Pattern 2: Progress dashboard**
```
Claude writes HTML → opens it → shows current progress
User reads dashboard → continues in chat
```
Use for: curriculum overview, module progress, skill map.

**Pattern 3: Interactive exploration (rare)**
```
Claude writes HTML with controls and prompt output → opens it
User interacts → copies generated prompt → pastes in chat
Claude acts on pasted prompt
```
Use for: concept maps, design playgrounds — only when visual interaction
is essential to the learning goal.

**Pattern 4: Before/after comparison**
```
Claude writes HTML showing diff/comparison → opens it
User reads → discusses in chat
```
Use for: showing what a commit changed, comparing markdown styles.

## What this means for lesson kits

The `visuals/` directory in each lesson kit should contain:

```
visuals/
├── overview.html          # Self-contained HTML (rich visual)
├── overview.md            # Markdown fallback (same content, text-only)
└── style.css              # Shared design tokens (imported at build time)
```

Or, for parameterized templates:

```
visuals/
├── overview.template.html # Template with {{slots}} Claude fills at runtime
├── overview.md            # Markdown fallback
└── style.css              # Shared tokens
```

Claude reads the template, fills slots with runtime context (user's actual
file names, their commit message, etc.), writes the populated HTML to a
temp location, and opens it.

## Open questions

1. **VS Code preview pane** — Can Claude Code actually invoke
   `code --preview`? Need to test empirically.
2. **Auto-open policy** — Should Claude auto-open visuals, or ask first?
   Beginners might be startled by unexpected browser windows.
3. **Template vs. generation** — For simpler visuals, is a parameterized
   template better than Claude generating HTML from scratch? (Probably yes
   for consistency; the playground plugin validates this pattern.)
4. **Shared style kit** — Should we ship a CSS file/design system for
   visual consistency, or inline everything per the playground pattern?
5. **Fallback fidelity** — How much effort to spend on markdown fallbacks?
   Bare-minimum text, or genuinely useful ASCII layouts?

## Recommendation

Adopt the **"visuals are projections" principle**: rich HTML for display,
chat for interaction. Build parameterized templates for core lesson
moments. Accept the copy-paste pattern only for rare interactive
explorations. Always provide markdown fallbacks. Test VS Code preview
automation as the first empirical spike.
