# Global preferences (all projects)

Personal defaults for every repo. A project's own CLAUDE.md owns its stack-specific
commands and standards and wins on any conflict. Follow these regardless of which
model is running — when in doubt, take the slower path that includes the
verification step.

## Orchestrating subagents

Use subagents when a task contains multiple concrete, independent workstreams and
delegation would materially improve speed, context management, or confidence. Do not
spawn subagents for simple or tightly sequential work, and do not delegate if I ask
you to work directly.

Routing — keep the main orchestrator on the user-selected model; route models and
effort for subagents:

- Choose the least expensive model likely to complete the assignment reliably:
  haiku for clear, repeatable, or high-volume tasks; sonnet for routine
  investigation and implementation; the session's top model (fable, or opus when
  fable is unavailable) for ambiguous, high-risk, cross-cutting, or deeply
  reasoned work.
- Choose reasoning effort independently, using the lowest level likely to succeed:
  low for straightforward work, medium for multi-step work, high for difficult work
  involving uncertainty, important tradeoffs, or extensive validation. Escalate the
  model or effort when results are uncertain or verification fails.

Assignments:

- Delegate investigation and implementation alike when work divides into bounded,
  independently useful units; launch independent assignments as one parallel batch.
- Prefer parallel delegation for exploration, research, test execution, log
  analysis, and independent review.
- An implementation subagent gets explicit ownership of files, modules, or behavior,
  plus the expected result and verification requirements. Ownership never overlaps:
  one owner for shared or tightly coupled code.
- Each implementation agent makes its changes, runs focused verification, and
  returns a concise summary of edits, tests, and remaining concerns.
- Default to no more than three subagents unless the task clearly benefits from
  greater fan-out. This cap does not apply to long autonomous runs (below).

Checkpoints:

- While subagents run, continue useful orchestration or integration work, but never
  edit areas owned by an active subagent and never redo work you've delegated.
- When results arrive, inspect the combined changes, reconcile contradictions,
  resolve integration issues, and run integrated verification.
- The main agent remains responsible for architectural decisions, final integration,
  validation, and the final response.

## Long autonomous runs

When I set you loose on a long unattended run (overnight builds, multi-ticket
sweeps, any session expected to span many tasks), context is the scarce resource —
auto-compact cannot be relied on, and a session pinned at full context burns tokens
on every turn. Protect the orchestrator's context:

- Act as a coordinator only: delegate all substantive reading, implementation, and
  test runs to subagents or workflows. Never read large files, full diffs, or test
  logs into your own context — ask an agent for the specific fact you need.
- Every agent returns a small structured summary (files changed, verification run,
  remaining concerns) — never transcripts, code listings, or long prose. In
  workflow scripts, use the `schema` option to force compact returns.
- One subagent per ticket/slice; fan out as widely as useful.
- Prefer many fresh sessions over one marathon: when work divides into slices,
  structure it so each slice runs in its own session (scheduled/cloud agents, a
  per-slice loop) rather than accumulating everything in one window.
- Persist progress outside the conversation (tracker tickets, commits, a handoff
  file) so a compaction or restart loses nothing.

## Feature flow

Every feature follows the same five skills, in this order — one flow, every time,
in every repo. Each is a slash command; drive the flow yourself, invoking each in
turn as the work is ready for it — you don't need me to type them. Still stop at the
flow's own decision gates (design approval, review findings that need my judgement).

1. **Design** — `/grill-with-docs` for a bounded design: a relentless interview
   that sharpens the plan and lays down ADRs + glossary as it goes. Use
   `/wayfinder` instead when the work is too big for one agent session and the
   route to the destination is still foggy.
2. **Spec** — `/to-spec` synthesizes the conversation so far into a spec and
   publishes it to the project tracker with the `ready-for-agent` label. No fresh
   interview — it captures what we already decided.
3. **Tickets** — `/to-tickets` breaks the spec into tracer-bullet vertical slices,
   each declaring its blocking edges, published to the tracker. Independently
   implementable, single-context-sized pieces, never one mega PR.
4. **Implement** — `/implement` builds the spec/tickets, using `/tdd` at the
   pre-agreed seams, typechecking and running single test files as it goes and the
   full suite at the end, then runs `/code-review` and commits.
5. **Review** — `/code-review` gives a two-axis read of the diff (Standards + Spec)
   in parallel sub-agents. Fix anything benign automatically; bring me anything
   that needs closer judgement.

## Coding

- Read a file and the code that calls it before changing it; match the existing
  pattern unless you have a stated reason not to.
- For bugs: reproduce first, diagnose until you can explain *why* it happens, then
  fix the root cause. If you can't reproduce it, report that instead of fixing blind.
- Before a multi-step task, write a short plan: the steps, the files you'll touch,
  and how you'll verify the result. For design choices with several defensible
  options, give one recommendation with reasons — never an options menu with no
  opinion.
- Make the smallest change that solves the problem properly. No drive-by refactors
  or style fixes outside the task.
- Edit files one at a time. Don't bulk-edit with sed/awk or scripted
  find-and-replace.
- Give public/exported functions and modules a docstring (or JSDoc); skip trivial
  private helpers.
- Never query inside a loop. A route's query count must not grow with the number of
  rows it renders: batch with one `IN (…)` / `JOIN` / `GROUP BY` and key the results
  in memory. When adding a per-row value to a list, extend the list's existing query
  rather than adding a per-row call.

## Tests

- Write tests for new features and bugfixes unless I say otherwise; cover the happy
  path and the edge cases.
- For a bugfix, write the failing test first and watch it fail — a test that never
  failed proves nothing about the fix.
- All tests must pass before committing — including after a refactor.
- Never change a test just to make it pass. Fix the code under test; only edit a
  test when I explicitly ask.

## Verification and self-review

- Run the checks the project actually defines — its test command, plus
  lint/type-check only if the repo configures them (package.json scripts, Makefile,
  pyproject.toml, etc.). Don't invent commands a project doesn't have.
- Tests alone aren't proof for a change with a runtime surface: exercise the
  affected code path at least once (run the CLI, hit the endpoint, drive the flow).
- Before presenting or committing, reread the complete diff as a skeptical reviewer:
  the input or state that breaks it, leftover debug code, changed files that
  shouldn't be in the diff.
- When I give review feedback, verify it's technically right before implementing.
  If it's wrong, push back with evidence.

## Git

- Stage with `git add -A`, after a quick `git status` to confirm nothing unintended
  is included.
- You may commit once a unit of work is complete AND verified (tests pass) — never
  a half-reviewed change or a mid-revision iteration.
- Squash fix-ups: a logical change is one clean commit. If you already committed and
  I ask for changes, amend it (while it's unpushed) rather than stacking "fix"
  commits.

## UI changes

- In-app copy for AI-backed features never says "AI" (or names a model/vendor):
  describe the help and its source ("Generate from datasheet"), not the mechanism.
  We disclose AI, we just don't lead with it: marketing and legal pages may name it.
  Applies to any string a user can see, including stored errors that surface in
  tooltips.
- All designs should keep in mind red green color deficiencies and be easy to see and read things.

## Business copy

- Any user-facing business copy — landing/marketing pages, lifecycle or sales
  emails, onboarding, pricing, sales collateral — follows the business-copy skill
  (`~/.claude/skills/business-copy/SKILL.md`). Invoke it before writing or
  reviewing such copy.

## Running things

- Assume the dev server is already running. If one is needed and isn't up, ask me
  to start it — don't launch it yourself.
- Env vars are loaded from `.env` by the framework, not exported to the shell. When
  a command needs one, source `.env` or pass it inline for that command. Never
  paste secret values into files or committed code.

## graphify

- **graphify** (`~/.claude/skills/graphify/SKILL.md`) — any input to knowledge
  graph. Trigger: `/graphify`. When I type `/graphify`, or a tool wants to explore
  the codebase, use the installed graphify skill or instructions before doing
  anything else.

## Instruction files

- When editing any CLAUDE.md (this file or a project's): keep it lean, only
  high-signal facts that would cause a mistake if removed; hard "must happen every
  time" gates belong in hooks, not prose.
- This file stays stack-agnostic: stack-specific commands and conventions live in
  project files (~50 repos: mostly Next/TS, Ruby, Go).
