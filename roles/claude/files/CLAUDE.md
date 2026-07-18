# Global preferences (all projects)

Personal defaults for every repo. A project's own CLAUDE.md owns its stack-specific
commands and standards and wins on any conflict.

## Orchestrating subagents

Use subagents when a task has multiple concrete, independent workstreams and
delegation materially improves speed, context management, or confidence. Not for
simple or tightly sequential work, and not when I ask you to work directly.

Routing — keep the orchestrator on the user-selected model; route each subagent:

- Every spawn — Agent tool calls and workflow-script `agent()` calls alike — must
  pass an explicit model. Omitting it silently inherits the session model; never
  omit, even where tool docs say inheriting is fine.
- Pick the least expensive model likely to succeed: haiku for clear, repeatable,
  or high-volume tasks; sonnet for routine investigation and implementation (the
  default when unsure); opus only when you can name why sonnet would fail —
  genuine ambiguity, a high-risk cross-cutting change, adversarial verification
  of a hard finding. Opus is the top of the routing ladder: never route a
  subagent to fable unless I ask for it by name, even when the session itself
  runs on fable.
- Same principle for reasoning effort: lowest level likely to succeed (low →
  medium → high). Escalate model or effort when verification fails.

Working rules:

- Default to ≤3 subagents unless the task clearly benefits from more (no cap on
  long autonomous runs).
- Implementation agents get explicit, non-overlapping ownership of files or
  behavior, plus the expected result and verification requirements; each returns
  a concise summary of edits, tests, and remaining concerns.
- Never edit areas owned by an active subagent or redo delegated work. You own
  architecture, integration, integrated verification, and the final response.

## Long autonomous runs

On long unattended runs (overnight builds, multi-ticket sweeps, sessions spanning
many tasks), the orchestrator's context is the scarce resource:

- Coordinate only: delegate substantive reading, implementation, and test runs.
  Never pull large files, full diffs, or test logs into your own context — ask an
  agent for the specific fact you need.
- Agents return small structured summaries (files changed, verification run,
  remaining concerns) — never transcripts or code listings. In workflow scripts,
  use the `schema` option to force compact returns.
- Model routing above applies with full force here: set `opts.model` (and
  `opts.effort`) on every workflow `agent()` call — a long run of
  inherited-session-model agents is this mode's most expensive failure.
- One subagent per ticket/slice; prefer many fresh sessions (scheduled/cloud
  agents, a per-slice loop) over one marathon window.
- Persist progress outside the conversation (tracker tickets, commits, a handoff
  file) so a compaction or restart loses nothing.

## Feature flow

Every feature follows the same five skills, in order — one flow, every time, in
every repo. Drive the flow yourself, invoking each in turn; still stop at the
flow's decision gates (design approval, review findings needing my judgement).

1. **Design** — `/wayfinder` for the design: route-finding interview that
   sharpens the plan before any code.
2. **Spec** — `/to-spec` synthesizes the conversation into a spec, published to
   the tracker with the `ready-for-agent` label. No fresh interview.
3. **Tickets** — `/to-tickets` breaks the spec into tracer-bullet vertical
   slices with declared blocking edges — single-context-sized, never one mega PR.
4. **Implement** — `/implement` builds the tickets, `/tdd` at pre-agreed seams,
   full suite at the end, then `/code-review` and commit.
5. **Review** — `/code-review` reads the diff on two axes (Standards + Spec) in
   parallel sub-agents. Fix benign findings automatically; bring me the rest.

## Coding

- Bugs: reproduce first, diagnose until you can explain *why*, then fix the root
  cause. If you can't reproduce it, report that instead of fixing blind.
- Smallest change that solves the problem properly; no drive-by refactors or
  style fixes outside the task.
- Edit files one at a time — no sed/awk or scripted find-and-replace.
- Never query inside a loop: a route's query count must not grow with the rows
  it renders — batch with one `IN (…)` / `JOIN` / `GROUP BY` and key results in
  memory. Extend a list's existing query rather than adding a per-row call.

## Tests

- Write tests for new features and bugfixes unless I say otherwise; happy path
  plus edge cases.
- For a bugfix, write the failing test first and watch it fail.
- All tests pass before committing — including after a refactor.
- Never change a test just to make it pass. Fix the code under test; only edit a
  test when I explicitly ask.

## Verification and self-review

- Run the checks the project actually defines (test command, plus lint/type-check
  only if configured). Don't invent commands a project doesn't have.
- Tests alone aren't proof for a change with a runtime surface: exercise the
  affected code path at least once (run the CLI, hit the endpoint, drive the flow).
- When I give review feedback, verify it's technically right before implementing.
  If it's wrong, push back with evidence.

## Git

- Stage with `git add -A` after a quick `git status` confirms nothing unintended.
- A logical change is one clean commit: if I ask for changes after you commit,
  amend the unpushed commit rather than stacking "fix" commits.

## UI changes

- In-app copy for AI-backed features never says "AI" (or names a model/vendor):
  describe the help and its source ("Generate from datasheet"), not the
  mechanism. Marketing and legal pages may name it. Applies to any string a user
  can see, including stored errors surfaced in tooltips.
- Designs must stay legible with red-green color deficiency.

## Business copy

- Any user-facing business copy (landing/marketing, lifecycle or sales emails,
  onboarding, pricing, collateral) follows the business-copy skill
  (`~/.claude/skills/business-copy/SKILL.md`) — invoke it before writing or
  reviewing such copy.

## Running things

- Check for an already-running dev server and use it; only start your own when
  none is up, and shut down any server you started when you're done.
- Env vars load from `.env` via the framework, not the shell: source `.env` or
  pass inline per command. Never paste secret values into files or committed code.

## graphify

- When I type `/graphify`, or a task means exploring a codebase's structure, use
  the graphify skill (`~/.claude/skills/graphify/SKILL.md`) before anything else.

## Instruction files

- When editing any CLAUDE.md: keep it lean — only high-signal facts that would
  cause a mistake if removed; hard "every time" gates belong in hooks, not prose.
- This file stays stack-agnostic: stack-specific commands and conventions live in
  project files (~50 repos: mostly Next/TS, Ruby, Go).
