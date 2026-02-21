# R&D: User Journey Design

## Who is the user?

Working assumptions (to be validated):

- **Not a developer.** May have never used a terminal, git, or markdown.
- **Curious about AI agents.** Has heard about Claude Code, wants to understand
  what "working with an AI agent" actually means.
- **Goal: become agent-native.** Wants to be able to use Claude Code as a
  thinking partner / force multiplier in their real work (likely PM, ops,
  strategy, or similar knowledge work).

## What does "done" look like?

After going through this project, the user should be able to:

1. Open a repo in Claude Code and orient themselves
2. Have a productive back-and-forth with Claude Code on a real task
3. Understand what CLAUDE.md does and how to shape Claude's behavior
4. Use skills/slash commands confidently
5. Read and write markdown comfortably
6. Make basic git operations (commit, push, branch) with Claude's help
7. Know how to structure a project so Claude Code is maximally useful
8. Understand the mental model: what agents are good/bad at, how to delegate

## Journey structure — options to consider

### Option A: Linear chapters
Like a book. Chapter 1, 2, 3... Simple, predictable, may feel rigid.

### Option B: Module map
Modules that can be done in any order after a shared intro. More flexible,
harder to sequence prerequisite knowledge.

### Option C: Challenge-driven
A series of increasingly complex challenges, each teaching a concept.
"Learn by doing" — could be engaging, but needs careful scaffolding.

### Option D: Guided conversation
CLAUDE.md and skills are set up so that Claude Code *is* the guide. The user
just talks to Claude and gets routed to the right content. Most "agent-native"
approach, but hardest to build and test.

## Open questions

1. How much do we teach *about* git/markdown/CLI vs. just use them through Claude?
   (i.e., does the user need to understand git, or just know Claude can do git things?)

2. How long is the experience? One sitting? A week? Self-paced modules?

3. Is there a "graduation" moment? A capstone project?

4. How do we handle the user who already knows some of this?
   (Skip ahead? Detect and adapt?)

## Next steps

- [ ] Write 2-3 user personas with more detail
- [ ] Sketch the first 3 "beats" of the journey (regardless of structure)
- [ ] Prototype one module/chapter/challenge to test the format
