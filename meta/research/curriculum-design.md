---
status: unread
criticality: critical
date: 2026-02-21
summary: 22 lessons across 7 modules, lesson state via curriculum.md, file structure, bootstrap skills
---

# R&D: Curriculum Design

## Design constraints

Working backwards from the user-journey-design.md "done" state, and informed
by what we now know about skills, @imports, and hooks.

**The learner**: Not a developer. May be new to terminal, git, markdown. Wants
to become agent-native for knowledge work.

**The medium**: The repo IS the classroom. Claude IS the guide. Lessons are
experienced through conversation, not read off a page.

**The tools at our disposal**:
- Skills (`.claude/skills/<name>/SKILL.md`) — can deliver lesson content, take
  arguments, restrict tools, fork into subagents
- @imports in CLAUDE.md — can pull in curriculum state at session start
- Hooks — can inject context (SessionStart), track state (SessionEnd)
- Nested CLAUDE.md — loaded when Claude works in child directories

---

## Lesson candidates

Organized into modules. Modules 0–2 are sequential (foundational). Modules 3–5
can flex in order. Module 6 is a capstone.

### Module 0: Welcome

*Get comfortable. Understand what this is.*

| # | Lesson | What happens |
|---|--------|-------------|
| 0.1 | What is this place? | Explore the repo structure with Claude. See that it's both a classroom and a tool. Learn what "agentic" means in practice. |
| 0.2 | Your first conversation | Have a real back-and-forth with Claude. Learn that how you ask matters. Experience the difference between vague and specific prompts. |
| 0.3 | Reading together | Ask Claude to read a file. See that Claude can navigate the repo, summarize, explain. First taste of delegation. |

### Module 1: Speaking Markdown

*Get comfortable with the lingua franca of this world.*

| # | Lesson | What happens |
|---|--------|-------------|
| 1.1 | Writing your first markdown | Create a simple .md file — headings, lists, bold, links. See it rendered. |
| 1.2 | Markdown as a thinking tool | Use markdown to structure an idea (not just format text). Outlines, pros/cons lists, decision docs. |
| 1.3 | Reading the room | Read CLAUDE.md and README.md as examples of markdown doing real work. Understand these aren't just docs — they're instructions. |

### Module 2: Making Changes

*Learn that you can change things and track those changes.*

| # | Lesson | What happens |
|---|--------|-------------|
| 2.1 | Your first edit | Edit a file with Claude's help. See the change. |
| 2.2 | What just happened? | Understand git tracks changes. See a diff. Grasp "before and after." |
| 2.3 | Your first commit | Commit a change. Understand what a commit is (a save point with a message). |
| 2.4 | The safety net | Learn that git means you can always go back. Try reverting a change. |

### Module 3: Shaping Claude

*Understand how to customize Claude's behavior.*

| # | Lesson | What happens |
|---|--------|-------------|
| 3.1 | What is CLAUDE.md? | Read the root CLAUDE.md. Understand it's a set of instructions Claude follows. |
| 3.2 | Change Claude's behavior | Edit CLAUDE.md (add a rule or persona tweak), start a new session, see the difference. |
| 3.3 | The context model | What Claude knows (files, CLAUDE.md, conversation history) vs. what it doesn't (anything you haven't shown it). |
| 3.4 | Writing good instructions | Principles: be specific, give examples, state what NOT to do. Practice rewriting a vague instruction. |

### Module 4: Skills & Commands

*Learn the skill system — both using and building.*

| # | Lesson | What happens |
|---|--------|-------------|
| 4.1 | Your first slash command | Use a built-in skill. See how it changes Claude's behavior for a specific task. |
| 4.2 | Inside a skill | Open a SKILL.md file. Understand frontmatter + instructions. See that skills are just markdown telling Claude what to do. |
| 4.3 | Build your own | Create a simple skill from scratch. Test it. Iterate on it. |
| 4.4 | Skills as workflows | Combine a skill with CLAUDE.md context to create a repeatable workflow for a real task. |

### Module 5: Working as Partners

*The soft skills of human-agent collaboration.*

| # | Lesson | What happens |
|---|--------|-------------|
| 5.1 | How to delegate | Break a task into pieces Claude can handle. Learn what's a good unit of delegation. |
| 5.2 | Reviewing Claude's work | Check output for correctness. Give specific feedback. Iterate. |
| 5.3 | When Claude gets it wrong | Understand hallucination, context limits, and task mismatch. Practice recovering. |
| 5.4 | The art of context | How to set Claude up for success: what to include, what to reference, when to provide examples. |

### Module 6: Project Craft (Capstone)

*Apply everything to a real project.*

| # | Lesson | What happens |
|---|--------|-------------|
| 6.1 | Starting from scratch | Set up a new repo with a CLAUDE.md tailored to a real task. |
| 6.2 | Organizing for agents | File structure, naming, documentation that makes Claude maximally useful. |
| 6.3 | Your workflow | Design a personal workflow combining CLAUDE.md, skills, and conversation patterns. |

---

## Lesson state

### The problem

We need to represent: which lessons are complete, skipped, or in progress. This
state must be readable by both Claude (to know where to pick up) and the human
(to see their progress).

### Recommendation: `curriculum.md` as progress tracker

A markdown file with checkboxes — the simplest thing that works for both audiences.

```markdown
# Curriculum

## Module 0: Welcome
- [x] What is this place?
- [x] Your first conversation
- [ ] Reading together          ← Claude picks up here

## Module 1: Speaking Markdown
- [ ] Writing your first markdown
- [ ] Markdown as a thinking tool
- [ ] Reading the room
```

**State markers:**
- `[ ]` — not started
- `[x]` — completed
- `[-]` — skipped (user chose to skip; Claude notes why if relevant)
- `[>]` — in progress (started but not finished; useful for multi-session lessons)

**Who reads it:** Claude, via @import in root CLAUDE.md. At session start Claude
knows exactly where the user is. The human reads it as a visible progress bar.

**Who writes it:** Claude updates it when a lesson is completed (or a `/complete`
skill does). The update is part of the lesson flow — Claude says "Nice work,
let me mark that off" and edits the file. This *itself* teaches git (the user
sees a change, can commit it).

**Committed or gitignored?** Committed. The user's progress IS part of their
repo state. The diff between the clean template and their version is their
journey. This also means progress survives across machines if they push.

### How Claude uses it

Root CLAUDE.md would include:

```markdown
@curriculum.md
```

On session start, Claude loads the curriculum, sees the state, and knows:
- What the user has completed
- Where to suggest picking up
- What prerequisites are met for flexible-order modules

### Alternative considered: JSON/YAML state file

More machine-readable but less human-friendly. Violates the "everything is
markdown" convention. Adds a parsing step. Rejected — the checkbox format is
readable by both audiences with zero tooling.

---

## File structure

### Proposed layout

```
hello-claude-code/
├── CLAUDE.md                    # User-facing guide persona; @imports curriculum.md
├── curriculum.md                # Progress tracker + lesson map
├── lessons/
│   ├── 00-welcome/
│   │   ├── CLAUDE.md            # Module-level context (loaded when Claude works here)
│   │   ├── what-is-this.md      # Lesson file (agent-primary)
│   │   ├── first-conversation.md
│   │   └── reading-together.md
│   ├── 01-markdown/
│   │   ├── CLAUDE.md
│   │   └── ...
│   ├── 02-making-changes/
│   ├── 03-shaping-claude/
│   ├── 04-skills/
│   ├── 05-working-together/
│   └── 06-project-craft/
├── .claude/
│   ├── skills/
│   │   ├── lesson/SKILL.md      # /lesson — start or resume next lesson
│   │   ├── complete/SKILL.md    # /complete — mark current lesson done
│   │   ├── skip/SKILL.md        # /skip — skip current lesson
│   │   └── progress/SKILL.md    # /progress — show curriculum state
│   ├── builder-context.md
│   ├── hooks/
│   └── settings.json
├── meta/                        # Builder workspace (unchanged)
└── .builder-mode                # (gitignored toggle)
```

### Lesson file format

Each lesson file is **agent-primary with a human-readable header**. The file
is a script for Claude, but opens with a brief summary a curious human could
read without spoilers.

```markdown
# What is this place?

> You'll explore this repo with Claude and learn what "working with an AI
> agent" actually feels like.

---

<!-- Agent instructions below -->

## Setup
[Any preconditions — files that should exist, prior lessons completed]

## Flow
[Step-by-step guide for Claude: what to say, what to show, what to ask]

## Exercises
[Specific tasks for the user to try]

## Success criteria
[How Claude knows the lesson is "done" — what the user should have seen/done]

## Wrap-up
[What Claude says to close the lesson, transition to next]
```

The human sees the title and the quoted summary. The rest is Claude's playbook.
The `<!-- Agent instructions below -->` comment makes the boundary explicit.

### Module-level CLAUDE.md

Each lesson directory gets a `CLAUDE.md` that's loaded when Claude navigates
there. This provides module-level context without polluting the root CLAUDE.md.

```markdown
# Module 0: Welcome

The user is in the Welcome module. They are likely brand new.

- Be extra patient and encouraging
- Don't assume any technical knowledge
- Celebrate every small action they take

Lessons in this module: @what-is-this.md, @first-conversation.md, @reading-together.md
```

### The curriculum.md audience question

**Written for both, structured for agents.** The file is:
- Human-readable (markdown checkboxes, module headings, plain language)
- Agent-parseable (Claude can read checkbox state reliably)
- Editable by both (human can manually check a box; Claude can edit via tool)

This is the hybrid approach. No special syntax, no frontmatter, no JSON — just
markdown that happens to be structured enough for Claude to interpret.

---

## Bootstrap skills

Minimal set to ship with:

| Skill | Purpose | Notes |
|-------|---------|-------|
| `/lesson` | Start or resume the next lesson | Reads curriculum.md, finds next unchecked item, loads lesson file |
| `/complete` | Mark current lesson done | Updates curriculum.md, suggests next step |
| `/skip` | Skip current lesson | Marks `[-]`, records reason, moves on |
| `/progress` | Show curriculum state | Summarizes completion by module |

These are the "navigation" skills. Additional skills would be taught as part of
Module 4, where the user learns to build their own.

---

## Open questions for discussion

1. **Lesson granularity** — Are these the right lessons, or should some be
   split/merged? Is 22 lessons the right size?

2. **Module flexibility** — Should modules 3–5 truly be flexible order, or
   is there a natural sequence we should enforce?

3. **Capstone scope** — Module 6 asks users to start a new repo. Is that too
   ambitious? Should the capstone be something within this repo instead?

4. **Lesson file authorship** — Should lesson files be fully scripted (Claude
   follows a playbook) or loosely guided (Claude improvises around objectives)?

5. **The skip problem** — If a user skips foundational lessons, later lessons
   may not make sense. Should some lessons be unskippable prerequisites?

6. **Session boundaries** — Some lessons may take 5 minutes, others 30. Should
   we indicate expected time? Or let Claude adapt?

7. **The "already know this" user** — Should there be a placement mechanism
   (a quick assessment that lets Claude recommend where to start)?
