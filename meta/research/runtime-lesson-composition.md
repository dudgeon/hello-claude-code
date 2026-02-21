---
status: unread
criticality: critical
date: 2026-02-21
summary: Design exploration — runtime-composed lessons vs static content, and how to make users feel the intelligence
---

# Runtime Lesson Composition

How do we build a curriculum that's rich and evolvable, supports visual
rendering, but lets Claude compose and adapt lessons at runtime — so users
feel the intelligence of the system, not a slideshow?

## The tension

Two ends of a spectrum:

**Static lessons** — Authored HTML/markdown pages. Claude serves them up,
walks alongside. Predictable, polished, but the user is basically reading a
tutorial with a chatbot sidebar. Claude is a page-turner.

**Pure improvisation** — No authored content. Claude teaches from its training
data, adapts completely to the user. Maximum intelligence, but no visual
richness, no quality control, no curriculum coherence. Claude is a rambler.

Neither is what we want. The goal is a **middle architecture** where:

1. Curriculum authors provide **structure, goals, and rich materials**
2. Claude **composes the actual lesson** at runtime from those materials
3. The user experiences something that feels **responsive, intelligent, and
   visually rich** — not canned

## Proposed architecture: Lesson Kits

Instead of "lesson files that Claude reads aloud," we build **lesson kits** —
bundles of ingredients Claude draws from to compose a learning experience.

### What's in a kit

```
lessons/02-making-changes/first-commit/
├── LESSON.md          # Goals, prerequisites, success criteria, teaching notes
├── concepts/          # Atomic concept cards Claude can introduce when relevant
│   ├── what-is-a-commit.md
│   ├── staging-area.md
│   └── commit-messages.md
├── exercises/         # Concrete tasks, ordered by difficulty
│   ├── 01-stage-a-file.md
│   ├── 02-write-a-message.md
│   └── 03-commit-and-verify.md
├── visuals/           # Rich HTML/SVG content Claude can serve up
│   ├── git-timeline.html
│   ├── staging-diagram.html
│   └── before-after.html
├── examples/          # Example files, diffs, conversations
│   ├── good-commit-message.md
│   └── bad-commit-message.md
└── checks/            # Programmatic success checks (optional)
    └── verify.sh      # "Did they actually commit something?"
```

### How Claude uses a kit

Claude reads `LESSON.md` for goals and pedagogy. Then it **composes** the
lesson in real time:

- **Reads the room.** If the user already knows what staging is, skip the
  concept card. If they're confused, pull it in and explain.
- **Sequences dynamically.** Maybe start with the exercise and introduce
  concepts as they come up (learning by doing). Or start with a visual and
  then move to practice. Claude decides based on the user's energy and
  responses.
- **Serves visuals contextually.** Instead of "here's page 3 of the lesson,"
  Claude says "let me show you what just happened" and opens a diagram that
  illustrates the specific thing the user did.
- **Adapts depth.** A user who's racing ahead gets fewer concept cards and
  harder exercises. A user who's struggling gets more scaffolding and simpler
  examples.

### What the user experiences

The user never sees the kit structure. They experience a conversation where
Claude:

1. Knows what they're learning and why
2. Shows them things (diagrams, visualizations) at the right moment
3. Gives them things to do (exercises) that build on each other
4. Notices when they're stuck or bored and adjusts
5. Celebrates when they succeed (verified by actual checks, not vibes)

This feels intelligent because **it is** — Claude is making real pedagogical
decisions, not following a script.

## Visual rendering: templates vs generation

For the `visuals/` layer, there are three approaches:

### Option A: Fully authored HTML

Designers/authors create polished HTML files. Claude opens them at the right
moment.

- **Pro:** High visual quality, predictable, accessible
- **Con:** Rigid. Can't adapt to what the user actually did. Content-visual
  mismatch ("the diagram shows file.txt but they edited notes.md")
- **Feel:** Polished but generic

### Option B: Parameterized templates

Authors create HTML templates with slots. Claude fills in runtime values
before serving.

```html
<!-- staging-diagram.html -->
<div class="staged-files">
  {{#each staged_files}}
    <div class="file">{{this}}</div>
  {{/each}}
</div>
```

Claude runs `git status`, populates the template, writes a filled HTML file,
opens it.

- **Pro:** Visual quality of authored design + contextual accuracy
- **Con:** Template complexity. Need a rendering pipeline. Limited to
  anticipated variations.
- **Feel:** Polished AND personal — "it knows what I did"

### Option C: Claude-generated HTML

Claude writes HTML on the fly. No templates — just generates a page that
illustrates whatever needs illustrating.

- **Pro:** Maximum flexibility. Can visualize anything.
- **Con:** Visual quality varies. Slower. No design consistency without a
  style system. Harder to test/review.
- **Feel:** Impressive when it works, janky when it doesn't

### Recommended: B as default, C as escape hatch

Use **parameterized templates** for core lesson visuals — they're the best
balance of quality and intelligence. But give Claude permission to **generate
ad-hoc HTML** when no template fits (answering a tangential question,
illustrating an error the user hit, etc.).

This also gives us an evolution path:
1. Start with a few high-quality templates for key moments
2. When Claude generates good ad-hoc visuals, promote them to templates
3. Templates accumulate organically from actual usage patterns

### The style kit

To keep generated visuals consistent, provide a shared CSS/design system:

```
assets/
├── style.css          # Shared styles for all visuals
├── components.css     # Reusable visual components (file trees, diffs, etc.)
└── base.js            # Shared utilities (animation, interactivity)
```

Claude `<link>`s or inlines these when generating or filling templates. This
gives even ad-hoc pages a consistent look.

## Runtime composition vs static: what changes

### What stays authored

| Artifact | Why |
|---|---|
| Learning goals | Curriculum coherence requires human design |
| Success criteria | Need to be reliable and testable |
| Exercise definitions | The "what to do" needs to be concrete |
| Visual templates | Design quality requires human craft |
| Concept card content | Accuracy matters; want editorial review |
| Teaching notes | Pedagogical strategy shouldn't be improvised |

### What Claude decides at runtime

| Decision | How |
|---|---|
| Which concepts to introduce | Read user's prior progress + conversation |
| When to show a visual | Pedagogical judgment based on conversation flow |
| Exercise sequencing | Adapt to difficulty — skip easy ones, repeat hard ones |
| Depth of explanation | Match user's demonstrated knowledge level |
| When the lesson is "done" | Run success checks + assess conversation |
| Tangents and follow-ups | Respond to user curiosity with ad-hoc content |
| Tone and pacing | Mirror the user's energy and communication style |

### What this means for the curriculum file

`curriculum.md` stays as the progress tracker, but lessons aren't just
checkboxes — they're pointers to kits:

```markdown
## Module 2: Making Changes

- [ ] [First edit](lessons/02-making-changes/first-edit/) — Edit a file with Claude's help
- [>] [First commit](lessons/02-making-changes/first-commit/) — Stage, commit, verify
- [ ] [Reading diffs](lessons/02-making-changes/reading-diffs/) — Understand what changed
```

The path points to a kit directory, not a single file.

## "Feeling the intelligence" — specific moments

The user should feel Claude's intelligence at these moments:

1. **Adaptive pacing.** "You clearly already know this — let's skip ahead."
   (Not possible with static content.)

2. **Contextual visuals.** A diagram that shows *their* files, *their* commit,
   *their* branch — not a generic example.

3. **Recovery from confusion.** User is stuck → Claude detects it → pulls in a
   different concept card or tries a different explanation → user unsticks.
   (Script-following can't do this.)

4. **Connecting the dots.** "Remember when you edited CLAUDE.md in lesson 3?
   What you just did with skills is the same idea — giving Claude instructions."
   (Requires cross-lesson memory, which Claude has via curriculum.md + git
   history.)

5. **Genuine verification.** "Let me check... yes, your commit went through.
   Here's what the git log looks like now." (Not "click next to continue.")

6. **Handling the unexpected.** User does something the lesson didn't
   anticipate. Claude rolls with it, teaches from what happened. (Static
   content can't handle this at all.)

7. **Personalized capstone.** The final project isn't a prescribed exercise —
   Claude helps the user build something *they* care about, drawing on
   everything they learned.

## Implementation sequence

1. **Build one kit** — `first-commit` is a good candidate. Goals, 2-3 concept
   cards, 2-3 exercises, 1 parameterized visual, 1 success check.

2. **Build the `/lesson` skill** — Reads curriculum.md, finds next kit, loads
   LESSON.md, enters teaching mode. This is where runtime composition logic
   lives.

3. **Build the template renderer** — Simple: Claude reads template, substitutes
   values, writes filled HTML, opens preview. No build step.

4. **Build the style kit** — Minimal CSS that makes generated/filled HTML look
   consistent and good.

5. **Test with a real user** — Watch what Claude does well and poorly. Identify
   where more authored content helps vs. where Claude's improvisation is
   sufficient.

6. **Iterate** — Promote good ad-hoc visuals to templates. Add concept cards
   where Claude's explanations were weak. Remove scaffolding where Claude
   didn't need it.

## Open questions

1. **Kit granularity.** Is one kit per lesson right? Or should some lessons
   share concept cards across a module-level pool?

2. **Visual complexity ceiling.** How interactive can template visuals be?
   Simple diagrams, or full interactive explorations (drag-and-drop staging
   area simulator)?

3. **Concept card format.** Plain markdown? Structured with frontmatter
   (prerequisites, related concepts)? How much metadata does Claude need to
   make good sequencing decisions?

4. **Success check reliability.** Shell scripts checking git state are
   straightforward. But how do we verify softer goals like "understands the
   mental model of staging"?

5. **Cross-surface rendering.** Templates work great in VS Code preview. What's
   the terminal-only equivalent? Markdown fallback? ASCII art? Skip visuals
   entirely and lean harder on conversation?

6. **Kit evolution workflow.** When Claude generates a great ad-hoc visual,
   what's the actual process for promoting it to a template? Manual? A skill?
