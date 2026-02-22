# Backlog

Living list of work to do. Roughly priority-ordered within each section.

---

## Now (in flight or next up)

- [ ] Design the user journey — who is the user, what do they know, what do they learn, in what order?
- [x] ~~R&D: rich visual content in preview pane~~ → Resolved by ADR 004 (Desktop primary, CLI + projection backup)
- [x] ~~Decide primary surface~~ → Resolved by ADR 004
- [ ] Decide on content structure (chapters? modules? challenges?)
- [ ] Spike: Desktop `.claude/launch.json` pre-configuration — can we make embedded preview "just works" on clone?
- [ ] Spike: surface detection — how does Claude know if it's running in Desktop vs CLI so it can choose the right rendering path?

## Soon

- [ ] Build first learning module (likely: "What is Claude Code and what can it do?")
- [ ] Set up CLAUDE.md with project-level instructions for Claude Code sessions
- [ ] Design the skill/command layer — what `/slash` commands does the user get?
- [ ] Design interactive lessons where learners build, apply, and execute skills — both manual invocation and interactive/guided flows
- [ ] Define a minimalist bootstrap skill set to ship with — lesson navigation, skill authoring, CLAUDE.md evaluation, and lesson content delivery
- [ ] Build text fallback strategy for CLI users — defensive markdown (no complex tables), clear degradation messaging

## Later

- [ ] Fork-level style customization — build a skill (e.g. `/style`) that ingests a style guide and re-styles lesson content, so org forks can brand the experience without rewriting lessons
- [ ] IDE comfort pass — explore what we can do in-repo to make markdown-heavy workflows feel less alien to non-developer users (e.g. recommended extensions, workspace settings for markdown preview/styling, editor defaults)
- [ ] Accessibility pass on web content
- [ ] Packaging / distribution story (template repo? `degit`? GitHub "Use this template"?)
