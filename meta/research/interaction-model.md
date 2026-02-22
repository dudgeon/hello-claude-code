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

## Surface capabilities (empirical findings)

Research into the actual rendering capabilities of each surface reveals
significant differences:

| Capability | CLI (Terminal) | Desktop App | Web (claude.ai/code) |
|---|---|---|---|
| Syntax-highlighted code | Yes | Yes | Yes |
| Rendered markdown | **Partial/buggy** — raw `**bold**`, broken tables | Yes | Yes |
| Inline images | No | Via attachments | Via attachments |
| Diff view | Text-based (red/green) | Visual, file-by-file | Visual |
| HTML preview | **No** | **Yes — embedded browser** | Sandboxed only |
| Auto-open browser | No (needs MCP/extension) | **Yes (built-in)** | N/A |
| Dev server preview | Run only; user opens browser | **Auto-start + embedded preview** | Sandboxed |

**The Desktop app is the standout surface.** It has a built-in embedded
browser that can:
- Auto-detect and start dev servers
- Open an embedded browser showing the running app
- Take screenshots, inspect the DOM, click elements, fill forms
- Auto-verify changes after edits
- Store server config in `.claude/launch.json`

**The CLI is the weakest for visuals.** Markdown rendering is partial —
there are known bugs with tables (raw pipe characters), bold text, and
non-ASCII characters. There's no inline HTML preview at all.

**The web version** runs in a sandboxed cloud environment with filesystem
and network isolation. Dev servers can run inside the sandbox but aren't
easily accessible from the user's browser.

### The fundamental constraint

**There is no programmatic channel from a rendered HTML page back to Claude
Code.** The HTML runs in a browser (or VS Code webview or Desktop embedded
browser). Claude Code runs in a terminal/agent process. They cannot talk to
each other directly.

One exception: The Desktop app can take screenshots of the embedded preview
and inspect its DOM — so Claude can *observe* what the user sees. But this
is Claude observing the page, not the page sending events to Claude. The
user still can't click something in the HTML and have Claude react to it.

| Direction | Works? | How |
|---|---|---|
| Claude → Visual | Yes | Write HTML file, open it (auto in Desktop, manual elsewhere) |
| Visual → Claude | **No** | User must manually relay information back to chat |
| Claude → Visual (observe) | **Desktop only** | Screenshots + DOM inspection of embedded preview |
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

| Surface | How to open visuals | Automation | Markdown quality |
|---|---|---|---|
| **Desktop app** | Embedded browser preview | **Fully automatic** — best experience | Good |
| **VS Code** | VS Code webview or browser | Claude can invoke; user approves | Good |
| **Terminal (desktop)** | `open` / `xdg-open` launches browser | Claude can invoke; user approves | **Poor** — raw syntax, broken tables |
| **Terminal (remote/SSH)** | No browser available | Fallback to text-only | Poor |
| **claude.ai/code (web)** | Sandboxed; no browser access | Fallback to text-only | Good (web renderer) |

**Implications**:
- Every visual must have a **text fallback**. The visual enriches the
  experience but the lesson must work without it.
- The Desktop app is the **ideal surface** for this project — its embedded
  preview makes visuals seamless.
- CLI users get a **degraded but functional** experience. We should be
  honest about this in onboarding: "This works best in the Desktop app or
  VS Code. Terminal works but you'll miss the visual richness."
- CLI markdown rendering bugs mean even our *text* fallbacks need to be
  defensive — avoid complex tables, prefer lists and headers.

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

1. **Primary surface decision** — Should we declare Desktop app as the
   recommended surface and design for it first? The embedded preview
   makes a qualitatively different experience possible.
2. **Desktop `.claude/launch.json`** — Can we pre-configure this so the
   embedded preview "just works" when the user clones the repo?
3. **Auto-open policy** — Should Claude auto-open visuals, or ask first?
   Desktop preview feels natural; a surprise browser window from CLI
   might be jarring.
4. **Template vs. generation** — For simpler visuals, is a parameterized
   template better than Claude generating HTML from scratch? (Probably yes
   for consistency; the playground plugin validates this pattern.)
5. **Shared style kit** — Should we ship a CSS file/design system for
   visual consistency, or inline everything per the playground pattern?
6. **Fallback fidelity** — How much effort to spend on text fallbacks?
   CLI markdown is buggy, so even "markdown fallback" has limits. Might
   need to be plain-text-safe (lists, headers, no tables).
7. **Desktop screenshot loop** — Desktop can screenshot the embedded
   preview. Could Claude use this for a quasi-feedback loop (render
   visual → screenshot → verify it looks right → iterate)? Useful for
   generated HTML quality assurance.

## Recommendation

Adopt the **"visuals are projections" principle**: rich HTML for display,
chat for interaction. **Target Desktop app as primary surface** — its
embedded preview makes visuals seamless and even enables a screenshot-
based quality loop. Build parameterized templates for core lesson
moments. Accept the copy-paste pattern only for rare interactive
explorations. Provide text fallbacks that work in degraded CLI rendering
(avoid complex tables). Test Desktop `.claude/launch.json` pre-
configuration as the first empirical spike.
